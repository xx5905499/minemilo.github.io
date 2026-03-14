// PRO Multi Minigame System 🎮

api.setSpawnPoint(0,20,0)
api.setDeathLine(-40)

let currentGame="lobby"
let voting=true
let votes={zombie:0,bow:0,bedwars:0,parkour:0,tntrun:0,kitpvp:0}
let playerVotes={}
let kills={}
let beds={}
let teams={}
let alive={}

api.scoreboard.setTitle("Minefun Games")

/* ARENAS */
const arenas={
zombie:{x:0,y:20,z:0},
bow:{x:80,y:20,z:0},
bedwars:{x:160,y:20,z:0},
parkour:{x:240,y:20,z:0},
tntrun:{x:320,y:20,z:0},
kitpvp:{x:400,y:20,z:0}
}

/* JOIN */

api.on("join",(p)=>{
kills[p.id]=0
alive[p.id]=true
p.sendTitle("Minefun Games","Vote with !vote <game>",0x00ff00)
})

/* VOTING */

api.on("chat",(p,msg,cancel)=>{
if(msg.startsWith("!vote")){
cancel()
const game=msg.split(" ")[1]

if(votes[game]!=undefined){
if(playerVotes[p.id]) votes[playerVotes[p.id]]--

playerVotes[p.id]=game
votes[game]++

p.sendMessage(3,"Voted for "+game)
updateVoteBoard()
}
}
})

function updateVoteBoard(){
api.scoreboard.clear()

let i=0
for(const g in votes){
api.scoreboard.setLine(i,g+": "+votes[g])
i++
}
}

/* START GAME AFTER 20s */

api.setTimeout(()=>{
startWinningGame()
},20000)

function startWinningGame(){

voting=false

let winner="zombie"
let max=0

for(const g in votes){
if(votes[g]>max){
max=votes[g]
winner=g
}
}

startGame(winner)
}

/* START GAME */

function startGame(game){

currentGame=game

for(const [id,p] of api.players){

p.clearInventory()
p.setHealth(100)
alive[p.id]=true

const a=arenas[game]
p.setPosition(a.x,a.y,a.z)
}

api.sendTitle(game.toUpperCase(),"Game Started!",0xffcc00)

if(game=="zombie") startZombie()
if(game=="bow") startBow()
if(game=="bedwars") startBedwars()
if(game=="parkour") startParkour()
if(game=="tntrun") startTNTRun()
if(game=="kitpvp") startKitPvP()

}

/* WIN DETECTION */

function checkLastAlive(){

let count=0
let last=null

for(const id in alive){
if(alive[id]){
count++
last=id
}
}

if(count<=1 && last){
const p=api.players.get(last)
api.sendTitle(p.name+" Wins!","",0x00ff00)
endGame()
}

}

function endGame(){

api.setTimeout(()=>{
api.room.end()
},5000)

}

/* PLAYER DEATH */

api.on("playerDeath",(p)=>{
alive[p.id]=false
checkLastAlive()
})

/* ZOMBIE SURVIVAL */

let wave=0

function startZombie(){

wave=0

api.setInterval(()=>{

if(currentGame!="zombie") return

wave++
api.chat.sendMessage(2,"Wave "+wave)

for(let i=0;i<wave*2;i++){
api.spawnMob("Zombie",Math.random()*20-10,22,Math.random()*20-10)
}

if(wave%5==0){
api.spawnMob("Diamond Golem",0,22,0)
api.chat.sendMessage(1,"BOSS SPAWNED!")
}

},8000)

}

/* BOW BATTLE */

function startBow(){

for(const [id,p] of api.players){
p.giveItem(276,1)
}

}

/* BEDWARS WITH TEAMS */

function startBedwars(){

api.createTeam("red")
api.createTeam("blue")

let i=0

for(const [id,p] of api.players){

const team=i%2==0?"red":"blue"
teams[p.id]=team
p.setTeam(team)

if(team=="red"){
p.setSpawnPoint(150,20,0)
beds["red"]=true
api.setBlock(150,19,0,580)
}else{
p.setSpawnPoint(170,20,0)
beds["blue"]=true
api.setBlock(170,19,0,580)
}

i++
}

}

api.on("breakBlock",(p,pos)=>{

if(currentGame!="bedwars") return

if(pos.x==150 && pos.z==0 && pos.y==19){
beds["red"]=false
api.chat.sendMessage(1,"Red bed destroyed!")
}

if(pos.x==170 && pos.z==0 && pos.y==19){
beds["blue"]=false
api.chat.sendMessage(1,"Blue bed destroyed!")
}

})

api.on("playerRespawn",(p)=>{

if(currentGame!="bedwars") return

const t=teams[p.id]

if(beds[t]==false){
p.setSpectator(true)
p.sendTitle("Eliminated","Your bed is gone!",0xff0000)
}

})

/* PARKOUR */

let startTimes={}
let finished={}

function startParkour(){

for(const [id,p] of api.players){
startTimes[p.id]=Date.now()
finished[p.id]=false
}

}

api.on("playerMove",(p,from,to)=>{

if(currentGame=="parkour" && !finished[p.id]){

if(to.x>260){
finished[p.id]=true

const time=Math.floor((Date.now()-startTimes[p.id])/1000)

api.chat.sendMessage(3,p.name+" finished in "+time+"s")
}

}

/* TNT RUN */

if(currentGame=="tntrun"){

const bx=Math.floor(to.x)
const by=Math.floor(to.y)-1
const bz=Math.floor(to.z)

if(api.getBlock(bx,by,bz)==826){

api.setTimeout(()=>{
api.setBlock(bx,by,bz,0)
},300)

}

}

})

function startTNTRun(){

api.fillBlocks({x:300,y:18,z:-20},{x:340,y:18,z:20},826)

}

/* KIT PVP */

function startKitPvP(){

for(const [id,p] of api.players){
p.giveItem(276,1)
p.setSlot("armor",0,310,1)
}

}

api.on("playerAttack",(attacker,target,damage)=>{

if(currentGame=="kitpvp"){

if(target.getHealth()-damage<=0){
kills[attacker.id]=(kills[attacker.id]||0)+1
attacker.sendMessage(3,"Kills: "+kills[attacker.id])
}

}

})
