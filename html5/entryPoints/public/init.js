(function() {

    function autoReload() {
        if (!App.commandBus) {
            App.start();
            return
        }
        var socket = new ReconnectingWebSocket(App.commandBus);
        var opened = false;
        socket.onconnecting = function(e) {
            if (!opened) {
                document.getElementById("content").innerHTML = "Connecting... " + App.commandBus;
            }
        };
        socket.onopen = function(e) {
            opened = true;
            App.start();
        };
        socket.onmessage = function(e) {
            if ("command" in e.data) {
                var cmd = e.data["command"];
                if (cmd == "reload") {
                    window.location.reload(true);    
                }
                else if (cmd == "view") {
                    window.location.search = e.data["search"];
                    window.location.href = e.data["href"];
                } else {
                    console.log(e.data);
                }
            }
        };
    }

    function query() {
        var pairs = location.search.slice(1).split('&');
        var result = {};
        for (var i in pairs) {
            pair = pairs[i].split('=');
            result[pair[0]] = decodeURIComponent(pair[1] || '');
        }
        return result;
    }

    function start() {
        var q = query(),
            conf = App,
            entryPoint = q["run"] || conf["default"],
            dependencies = [],
            found = false;
        console.log();
        if (Object.keys(conf["entryPoints"]).indexOf(entryPoint) >= 0) {
            found = true;
            var refs = conf["entryPoints"][entryPoint];
            if (refs !== undefined || refs.length == 0) {
                for (var i in refs) {
                    dependencies = dependencies.concat(conf["dependencies"][refs[i]]);
                }
                dependencies.push("app/" + entryPoint + ".js");
                head.load(dependencies, autoReload);
            }
        }
        if (!found) {
            var html = "Add an entrypoint to app.js";
            if (Object.keys(conf["entryPoints"]).length > 0) {
                html = "";
                for (var id in conf["entryPoints"]) {
                    html += "<a href=\"?run=" + id + "\">" + id + "</a>";
                }
            }
            document.getElementById("content").innerHTML = html;
            throw "Couldn't find entryPoint";
        }
    }

    if (WebSocket === undefined) {
        document.getElementById("content").innerHTML = "A browser that supports Web Sockets is required.";
    } else {
        head.load(["app.js",  "js/reconnecting-websockets/reconnecting-websockets.js"], start);
    }

})();