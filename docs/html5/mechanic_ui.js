const gameui = document.getElementById("fnfgame");
const play_btn = document.getElementById("playbutton");
const full_btn = document.getElementById("fullscreen_btn");
const iframe_btn = document.getElementById("iframebutton");
const tv_container = document.getElementById('tv_container');

function enterFullscreen() {
    if (gameui.requestFullscreen) {
        gameui.requestFullscreen();
    } else if (gameui.webkitRequestFullscreen) {
        gameui.webkitRequestFullscreen();
    } else if (gameui.mozRequestFullScreen) {
        gameui.mozRequestFullScreen();
    } else if (gameui.msRequestFullscreen) {
        gameui.msRequestFullscreen();
    }
    gameui.focus();
}

function play() {
    gameui.src = "fnfhtml5/index.html";
    gameui.style.backgroundColor = "grey";
    iframe_btn.style.display = "flex";
    full_btn.style.display = "block";
    play_btn.style.display = "none";
    tv_container.style.pointerEvents = 'auto';
}

function restart() {
    gameui.src= gameui.src;
}

function shutdown() {
    gameui.src= "about:blank";
    gameui.style.backgroundColor = "black";
    iframe_btn.style.display = "none";
    full_btn.style.display = "none";
    play_btn.style.display = "block";
    tv_container.style.pointerEvents = 'none';
}

function press() {
    const presssound = new Audio('/Dragon-Engine/audio/click.mp3');
    presssound.currentTime = 0;
    presssound.play();
}