const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);
const PORT = 3001;

var numbers = []; // Not necessary a Server Variable. This is for testing.

// HTTP Request to Fill Data. 
app.post('/', function (req, res) {
    numbers.push(numbers.length);
    console.log(numbers);
    updateNumbers();
    res.status(200).send(numbers);
});

io.on('connection', function (socket) {
    console.log(`${socket.id} connected.`);
    socket.on("subRoom", function (data, fn) {
        const {room} = data;
        socket.join(room);
        pushInitialRoomData(socket, room); 
    });
    socket.on("unSubRoom", function (data, fn) {
        const {room} = data;
        socket.leave(room);
    });
});


function updateNumbers(socket) {
    // Updates Number Rooms. Called whenever we want to push changes to our app.
    const updateString = "numbersUpdate";
    const roomName = "numbers";
    var data = {
        data: numbers
    };
    if (socket) {
        socket.emit(updateString, data);
        return;
    }
    io.to(roomName).emit(updateString, data);
}

function pushInitialRoomData(socket, roomName) {
    // Initial Data for all your rooms.
    if (!socket) return;
    switch (roomName) {
        case "numbers":
            updateNumbers(socket);
            return;
        default:
            return;
    }
}


http.listen(PORT, function () {
    console.log("Listening on *:" + PORT);
});
