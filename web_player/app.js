let musicKit;
let queue = [];
let currentIndex = 0;
let isPlaying = false;

let initialized = false;

async function initializeMusicKit() {
    if (initialized) return;
    initialized = true;
    
    try {
        const response = await fetch('/token');
        const res = await response.json();
        
        musicKit = MusicKit.configure({
            developerToken: res.token,
            app: {
                name: 'Simple Music Player',
                build: '1.0.0'
            },
            storefrontId: "be"
        });
        
        // Listen for song end events
        musicKit.addEventListener('playbackStateDidChange', (event) => {
            const stateNames = {
                0: 'none', 1: 'loading', 2: 'playing', 3: 'paused', 
                4: 'stopped', 5: 'ended', 6: 'seeking', 7: 'waiting', 8: 'stalled'
            };
            console.log('Playback state changed:', event.state, '(' + stateNames[event.state] + ')');
            
            if (event.state === MusicKit.PlaybackStates.ended) {
                next();
            } 
        });

        // Set up controls
        document.getElementById('playBtn').addEventListener('click', play);
        document.getElementById('stopBtn').addEventListener('click', stop);
        document.getElementById('nextBtn').addEventListener('click', next);
        document.getElementById('prevBtn').addEventListener('click', previous);
        document.getElementById('loginBtn').addEventListener('click', login);

        // Start polling for queue updates
        pollQueue();
    } catch (error) {
        console.error('Failed to initialize MusicKit:', error);
    }
}

// Initialize Apple Music Kit
document.addEventListener('musickitloaded', initializeMusicKit);
document.addEventListener('DOMContentLoaded', () => {
    if (typeof MusicKit !== 'undefined') {
        initializeMusicKit();
    }
});

// Poll the JSON file for queue updates
function pollQueue() {
    setInterval(async () => {
        try {
            const response = await fetch('/queue');
            if (response.ok) {
                const commands = await response.json();
                document.getElementById('queueInfo').style.display = 'none';
                commands.forEach(command => {
                    if (command.action === 'add' && command.song && command.artist) {
                        addSongToQueue(command.song, command.artist, command.artwork, command.song_id, command.album);
                    } else if (command.action === 'remove' && command.song && command.artist) {
                        removeSongFromQueue(command.song, command.artist);
                    }
                });
            } else if (response.status === 404) {
                document.getElementById('queueInfo').style.display = 'block';
            }
        } catch (e) {
            // Silently handle errors (server might not be running)
            console.log(e);
        }
    }, 1000);
}

// Add song to queue
function addSongToQueue(song, artist, artwork, song_id, album) {
    // Check if song already exists in queue
    const exists = queue.some(item => item.song === song && item.artist === artist);
    if (exists) return;
    
    const newSong = { song, artist, artwork, song_id, album };
    queue.push(newSong);
    updateQueueDisplay();
}

// Remove song from queue
function removeSongFromQueue(song, artist) {
    const index = queue.findIndex(item => item.song === song && item.artist === artist);
    if (index !== -1) {
        queue.splice(index, 1);
        if (currentIndex >= index) {
            currentIndex = Math.max(0, currentIndex - 1);
        }
        updateQueueDisplay();
    }
}

// Update queue display
function updateQueueDisplay() {
    const queueList = document.getElementById('queueList');
    queueList.innerHTML = '';
    
    queue.forEach((item, index) => {
        const div = document.createElement('div');
        div.className = `song ${index === currentIndex ? 'current' : ''}`;
        
        if (item.artwork) {
            const img = document.createElement('img');
            img.src = item.artwork;
            img.className = 'artwork';
            div.appendChild(img);
        }
        
        const text = document.createElement('span');
        text.textContent = `${item.song} - ${item.artist}`;
        div.appendChild(text);
        
        queueList.appendChild(div);
    });
    
    updateNowPlaying();
}

// Update now playing display
function updateNowPlaying() {
    const currentSong = queue[currentIndex];
    const artwork = document.getElementById('currentArtwork');
    const title = document.getElementById('currentTitle');
    const artist = document.getElementById('currentArtist');
    const album = document.getElementById('currentAlbum');
    
    const nowPlayingSection = document.getElementById('nowPlayingSection');
    
    if (isPlaying && currentSong) {
        nowPlayingSection.style.display = 'block';
        title.textContent = currentSong.song;
        artist.textContent = currentSong.artist;
        album.textContent = currentSong.album || '';
        if (currentSong.artwork) {
            artwork.src = currentSong.artwork;
            artwork.style.display = 'block';
        } else {
            artwork.style.display = 'none';
        }
    } else {
        nowPlayingSection.style.display = 'none';
        title.textContent = '';
        artist.textContent = '';
        album.textContent = '';
        artwork.style.display = 'none';
    }
}

// Play current song
async function play() {
    if (!musicKit || queue.length === 0) return;
    
    try {
        const currentSong = queue[currentIndex];
        console.log('Attempting to play:', currentSong.song, 'ID:', currentSong.song_id);
        await musicKit.setQueue({ songs: [currentSong.song_id] });
        console.log('Queue set successfully');
        await musicKit.play();
        console.log('Play command sent');
        isPlaying = true;
        updateNowPlaying();
    } catch (error) {
        console.error('Error playing song:', error);
        console.error('Song details:', queue[currentIndex]);
    }
}

// Stop playback
function stop() {
    if (musicKit) {
        musicKit.stop();
        isPlaying = false;
        updateNowPlaying();
    }
}

// Login to Apple Music
async function login() {
    console.log('Login button clicked');
    try {
        console.log('Starting authorization...');
        const musicUserToken = await musicKit.authorize();
        console.log(`Authorized: ${musicUserToken}`);
    } catch (error) {
        console.error('Authorization failed:', error);
        alert(`Authorization failed: ${error.message}`);
    }
}

// Play previous song
function previous() {
    if (queue.length === 0) return;
    
    currentIndex = (currentIndex - 1 + queue.length) % queue.length;
    updateQueueDisplay();
    play();
}

// Play next song
function next() {
    if (queue.length === 0) return;
    
    if (currentIndex < queue.length - 1) {
        currentIndex++;
        updateQueueDisplay();
        play();
    } else {
        isPlaying = false;
        updateNowPlaying();
    }
}