function start()
{
    var logDiv = document.getElementById("log");
	if ("WebSocket" in window)
	{
		var ws = new WebSocket("%%WEBSOCKET_URL%%");
		ws.onopen = function()
		{
			logDiv.innerHTML += "websocket is open"  + "</br>";
		};
		ws.onmessage = function(evt) { logDiv.innerHTML += "received: " + evt.data + "</br>"; };
		ws.onclose = function() { logDiv.innerHTML += "websocket is closed" + "</br>"; };
        
        startWebRTC(ws);
	}
	else
	{
		alert("Browser doesn't support WebSocket!");
	}
}

function startWebRTC(ws)
{
	getUserMedia({audio: true}, function(stream){
		var connection = new RTCPeerConnection(null);
		connection.addStream(stream);
		
		connection.createOffer(function(desc){
			connection.setLocalDescription(desc, function(){
				console.log(desc["sdp"]);
				ws.send(JSON.stringify(desc));
			});
		});
		
		connection.onicecandidate = function(event) {
			if (event.candidate) {
				console.log(event.candidate);
				ws.send(JSON.stringify(event.candidate));
			}
		}
	});
}