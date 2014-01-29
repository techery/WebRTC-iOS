function log(msg) {
	console.log(JSON.stringify(msg));
}

function logError(error) {
	log(error.name + ': ' + error.message);
}

function start() {
	if ("WebSocket" in window) {
		var ws = new WebSocket("%%WEBSOCKET_URL%%");
		
        ws.onopen = function() {
			log("websocket is open");
			startWebRTC(ws);
		};
        
		ws.onclose = function() {
			log("websocket is closed");
			close();
		};
	} else {
		log("Browser doesn't support WebSocket!");
	}
}

function onHandShake(ws) {
	return function(event) {
        var message = JSON.parse(event.data);
        
        if (message.type == "handshake") {
            startWebRTC(ws);
        } else {
            alert("Invalid handshake\n Page will be reloaded");
            ws.close();
            window.location.reload(true);
        }
    }
}

function close() {
    if (window.rtcConnection) {
        window.rtcConnection.close();
    }

	document.getElementById("talking_view").style.display="none";
	document.getElementById("waiting_view").style.display="block";
}

function createAnswer(ws, cn, message) {
	cn.setRemoteDescription(new RTCSessionDescription(message), function() {
		cn.createAnswer(function(desc) {
			cn.setLocalDescription(desc, function() {
				log("Send answer");
				ws.send(JSON.stringify(cn.localDescription));
			}, logError)
		}, logError);
	}, logError);
}

function addCandidate(cn, message) {
	cn.addIceCandidate(new RTCIceCandidate(message));
}

function buildMessageHandler(ws, cn) {
	return function(event) {
		var message = JSON.parse(event.data);
		log(message);
		
		if (message.type == "offer") {
			createAnswer(ws, cn, message);
		} else if (message.type == "candidate") {
			addCandidate(cn, message);
		} else if (message.type == "bye") {
			close()
		}
	}
}

function toggleMic(stream) {
  var audioTracks = stream.getAudioTracks();
  for (var i = 0, l = audioTracks.length; i < l; i++) {
    audioTracks[i].enabled = !audioTracks[i].enabled;
  }
}

function createConnection(stream) {
    var cn = new RTCPeerConnection(null);
    window.rtcConnection = cn;
    cn.addStream(stream);
    toggleMic(stream);
    
    return cn;
}

function onIceCandidate(ws) {
    return function(event) {
        if (event.candidate) {
            event.candidate.type = "candidate";
            log(event.candidate);
            ws.send(JSON.stringify(event.candidate));
        };
    };
}

function onAddStream(event) {
	log(event);
	var video = document.getElementById("video");
	video.src = URL.createObjectURL(event.stream)
	document.getElementById("talking_view").style.display="block";
	document.getElementById("waiting_view").style.display="none";
	
	event.stream.onended = function() {
		close();
	}
}

function startWebRTC(ws) {
	getUserMedia({
		audio: true
	}, function(stream) {
        var cn = createConnection(stream);
		
		cn.onicecandidate = onIceCandidate(ws);
		cn.onaddstream = onAddStream;

		ws.onmessage = buildMessageHandler(ws, cn);
	});
}
