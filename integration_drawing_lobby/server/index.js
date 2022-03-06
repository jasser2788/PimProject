const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require("mongoose");
const Room = require('./models/Room');
var io = require("socket.io")(server);
const getWord = require('./api/getWord');

// middleware
app.use(express.json());

// Connect to our MongoDB
const DB = 'mongodb+srv://jesser:jCWtAA7tXdKVuZ1b@miniprojet.dpkeg.mongodb.net/pim?retryWrites=true&w=majority';

mongoose.connect(DB).then(() => {
    console.log('Connection Succesful!');
}).catch((e) => {
    console.log(e);
})

io.on('connection', (socket) => {
    console.log("Socket connected", socket.id)

    socket.on('disconnect', () => {
      console.log("Socket disconnect",socket.id)
    });
  
    socket.on('coordinates', (pointdata) => {
      console.log(pointdata);
      socket.broadcast.emit('receive', pointdata);
    })
    
    // CREATE GAME CALLBACK
    socket.on('create-game', async({nickname, name, occupancy, maxRounds}) => {
        try {
            const existingRoom = await Room.findOne({name});
            if(existingRoom) {
                socket.emit('notCorrectGame', 'Room with that name already exists!');
                return;
            }
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;

            let player = {
                socketID: socket.id,
                nickname,
                isPartyLeader: true,
            }
            room.players.push(player);
           
            socket.join(name);
            io.to(name).emit('updateRoom', room); 
            room = await room.save();
        } catch(err) {
            console.log(err);
        }
    });

    // JOIN GAME CALLBACK
    socket.on('join-game', async({nickname, name}) => {
        try {
            let room = await Room.findOne({name});
            if(!room) {
                socket.emit('notCorrectGame', 'Please enter a valid room name');
                return;
            }

            if(room.isJoin) {
                let player = {
                    socketID: socket.id,
                    nickname,
                }
                room.players.push(player);
                socket.join(name);

                if(room.players.length === room.occupancy) {
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('updateRoom', room);
            } else {
                socket.emit('notCorrectGame', 'The game is in progress, please try later!');
            }
        } catch(err) {
            console.log(err);
        }
    })

    socket.on('msg', async (data) => {
        console.log(data);
        try{
            if(data.msg === data.word) {
                let room = await Room.find({name: data.roomName});
                let userPlayer = room[0].players.filter(
                    (player) => player.nickname === data.username
                )
              
                room = await room[0].save();
               
                socket.emit('closeInput', "");
            } else {
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: data.msg,
                   
                })
            }
        } catch(err) {
            console.log(err.toString());
        }
    })

   socket.on('change-turn', async(name) => {
       
        try {
            let room = await Room.findOne({name});
            console.log(room.currentRound)

            let idx = room.turnIndex;
            if(idx +1 === room.players.length) {
                room.currentRound+=1;
            }
            if(room.currentRound <= room.maxRounds) {
                const word = getWord();
                room.word = word;
                room.turnIndex = (idx+1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('change-turn', room);
            } 
        } catch(err) {
            console.log(err);
        }
    })
    // Stroke Socket
    socket.on('stroke-width', ({value, roomName}) => {
        io.to(roomName).emit('stroke-width', value);
    })

    

    socket.on('disconnect', async() => {
        try {
            let room = await Room.findOne({"players.socketID": socket.id});
            for(let i=0; i< room.players.length; i++) {
                if(room.players[i].socketID === socket.id) {
                    room.players.splice(i, 1);
                    break;
                }
            }
            room = await room.save();
          
        } catch(err) {
            console.log(err);
        }
    })
})

server.listen(port, "0.0.0.0", () => {
    console.log('Server started and running on port ' + port);
})