// snake3d.js
const readline = require('readline');
const { stdin, stdout } = process;

const SIZE = 8;

class Snake3D {
    constructor() {
        this.size = SIZE;
        this.center = Math.floor(SIZE / 2);
        this.snake = [[this.center, this.center, this.center]];
        this.dir = [0, 0, 1];
        this.nextDir = [0, 0, 1];
        this.food = this.spawnFood();
        this.score = 0;
        this.high = 0;
        this.speed = 300;
        this.gameOver = false;
        this.paused = false;
        this.running = true;
        this.loop = null;
        this.inputQueue = [];
        this.setupInput();
        this.run();
    }

    spawnFood() {
        let pos;
        do {
            pos = [
                Math.floor(Math.random() * this.size),
                Math.floor(Math.random() * this.size),
                Math.floor(Math.random() * this.size)
            ];
        } while (this.snake.some(seg => seg[0] === pos[0] && seg[1] === pos[1] && seg[2] === pos[2]));
        return pos;
    }

    contains(pos) {
        return this.snake.some(seg => seg[0] === pos[0] && seg[1] === pos[1] && seg[2] === pos[2]);
    }

    update() {
        if (this.paused || this.gameOver) return;
        this.dir = [...this.nextDir];
        let head = this.snake[0];
        let newHead = [
            (head[0] + this.dir[0] + this.size) % this.size,
            (head[1] + this.dir[1] + this.size) % this.size,
            (head[2] + this.dir[2] + this.size) % this.size
        ];
        if (this.contains(newHead)) {
            this.gameOver = true;
            if (this.score > this.high) this.high = this.score;
            return;
        }
        this.snake.unshift(newHead);
        if (newHead[0] === this.food[0] && newHead[1] === this.food[1] && newHead[2] === this.food[2]) {
            this.score++;
            this.food = this.spawnFood();
            this.speed = Math.max(80, this.speed - 10);
        } else {
            this.snake.pop();
        }
    }

    render() {
        console.clear();
        console.log(`🐍 3D SNAKE   Score: ${this.score}   High: ${this.high}   Speed: ${(this.speed/1000).toFixed(2)}s`);
        console.log('Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit');
        // Render 3D slices
        for (let y = this.size - 1; y >= 0; y--) {
            for (let z = 0; z < this.size; z++) {
                let line = '';
                for (let x = 0; x < this.size; x++) {
                    let ch = '.';
                    if (this.contains([x, y, z])) ch = 'o';
                    if (this.snake[0][0] === x && this.snake[0][1] === y && this.snake[0][2] === z) ch = 'O';
                    if (this.food[0] === x && this.food[1] === y && this.food[2] === z) ch = '★';
                    line += ch + ' ';
                }
                console.log(line);
            }
        }
        if (this.paused) console.log('\n⏸️  PAUSED');
        if (this.gameOver) console.log('\n💀 GAME OVER! Press R to restart.');
    }

    setupInput() {
        readline.emitKeypressEvents(process.stdin);
        process.stdin.setRawMode(true);
        process.stdin.on('keypress', (str, key) => {
            if (key.ctrl && key.name === 'c') process.exit();
            if (key.name === 'space') { this.paused = !this.paused; return; }
            if (key.name === 'r' && this.gameOver) {
                this.snake = [[this.center, this.center, this.center]];
                this.dir = [0, 0, 1];
                this.nextDir = [0, 0, 1];
                this.food = this.spawnFood();
                this.score = 0;
                this.speed = 300;
                this.gameOver = false;
                return;
            }
            if (this.paused || this.gameOver) return;
            switch (key.name) {
                case 'w': this.nextDir = [0, 0, 1]; break;
                case 's': this.nextDir = [0, 0, -1]; break;
                case 'a': this.nextDir = [-1, 0, 0]; break;
                case 'd': this.nextDir = [1, 0, 0]; break;
                case 'q': this.nextDir = [0, 1, 0]; break;
                case 'e': this.nextDir = [0, -1, 0]; break;
                case 'up': this.nextDir = [0, 0, 1]; break;
                case 'down': this.nextDir = [0, 0, -1]; break;
                case 'left': this.nextDir = [-1, 0, 0]; break;
                case 'right': this.nextDir = [1, 0, 0]; break;
                case 'escape': this.running = false; process.exit();
            }
        });
    }

    run() {
        this.loop = setInterval(() => {
            this.update();
            this.render();
            if (this.gameOver) {
                // Wait for restart
            }
        }, this.speed);
    }
}

new Snake3D();
