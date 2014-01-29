function log(msg) {
	console.log(JSON.stringify(msg));
}

function logError(error) {
	log(error.name + ': ' + error.message);
}

function start() {
	var ws = new WebSocket("%%WEBSOCKET_URL%%");

	ws.onopen = function() {
		log("websocket is open");
		startWebRTC(ws);
	};

	ws.onclose = function() {
		log("websocket is closed");
		close();
	};
}

function close() {
	window.rtcConnection.close();
	window.rtcConnection = null;
}

function reset() {
	close();
	logDiv.innerHTML = "";
	document.getElementById("video").src = "";
}

function onAnserhandler(ws, cn) {
	return function(desc) {
		cn.setLocalDescription(desc, function() {
			log("Send answer");
			ws.send(JSON.stringify(cn.localDescription));
		}, logError)
	}
}

function onRemoteDescriptionSet(ws, cn) {
	return function() {
		cn.createAnswer(onAnserhandler(ws, cn), logError);
	}
}

function createAnswer(ws, cn, message) {
	cn.setRemoteDescription(new RTCSessionDescription(message), function() {
		onRemoteDescriptionSet(ws, cn)
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
			close();
		} else if (message.type == "reset") {
			reset();
		}
	}
}

function toggleMic(stream) {
	var audioTracks = stream.getAudioTracks();
	for (var i = 0, l = audioTracks.length; i < l; i++) {
		audioTracks[i].enabled = !audioTracks[i].enabled;
	}
}

function sendIceCandidate(ws) {
	return function(event) {
		var candidate = event.candidate;
		candidate.type = "candidate";
		log(candidate);
		ws.send(JSON.stringify(candidate));
	}
}

function streamHandler(event) {
	log(event);
	var video = document.getElementById("video");
	video.src = URL.createObjectURL(event.stream)
}

function onMediaReady(ws) {
	return function(stream) {
		var cn = new RTCPeerConnection(null);
		window.rtcConnection = cn;
		cn.addStream(stream);
		
		toggleMic(stream);

		cn.onicecandidate = sendIceCandidate(ws);
		cn.onaddstream = streamHandler;

		ws.onmessage = buildMessageHandler(ws, cn);
	}
}

function startWebRTC(ws) {
	getUserMedia({audio: true}, onMediaReady(ws));
}
