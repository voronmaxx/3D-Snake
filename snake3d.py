# snake3d.py
import os
import random
import time
import sys
import threading
from collections import deque

class Snake3D:
    def __init__(self, size=8):
        self.size = size
        self.center = size // 2
        self.snake = deque()
        self.snake.append((self.center, self.center, self.center))
        self.direction = (0, 0, 1)  # x, y, z
        self.next_direction = self.direction
        self.food = self._spawn_food()
        self.score = 0
        self.high_score = 0
        self.speed = 0.3
        self.game_over = False
        self.paused = False
        self.running = True

    def _spawn_food(self):
        while True:
            pos = (random.randint(0, self.size-1),
                   random.randint(0, self.size-1),
                   random.randint(0, self.size-1))
            if pos not in self.snake:
                return pos

    def _project_3d_to_2d(self, x, y, z):
        """Isometric projection: (x,y,z) -> (screen_x, screen_y)"""
        screen_x = (x - z) * 2 + self.size * 2
        screen_y = (x + z) + y * 2 + 2
        return screen_x, screen_y

    def _render(self):
        os.system('cls' if os.name == 'nt' else 'clear')
        print(f"🐍 3D SNAKE   Score: {self.score}   High: {self.high_score}   Speed: {self.speed:.2f}s")
        print("Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit")
        # Build grid view (isometric)
        # We'll render layer by layer from back to front
        layers = {}
        # Add snake segments
        for idx, seg in enumerate(self.snake):
            layers[seg] = 'O' if idx == 0 else 'o'
        # Add food
        layers[self.food] = '★'
        # Render
        for y in range(self.size-1, -1, -1):
            for z in range(self.size):
                line = []
                for x in range(self.size):
                    pos = (x, y, z)
                    if pos in layers:
                        line.append(layers[pos])
                    else:
                        line.append('.')
                print(' '.join(line))
        # Show 3D projection
        print("\n3D Isometric View:")
        screen = [[' ' for _ in range(self.size*4 + 4)] for _ in range(self.size*4 + 4)]
        for y in range(self.size):
            for z in range(self.size):
                for x in range(self.size):
                    pos = (x, y, z)
                    if pos in layers:
                        sx, sy = self._project_3d_to_2d(x, y, z)
                        if 0 <= sx < len(screen[0]) and 0 <= sy < len(screen):
                            screen[sy][sx] = layers[pos]
        for row in screen:
            print(''.join(row))
        if self.paused:
            print("\n⏸️  PAUSED")
        if self.game_over:
            print("\n💀 GAME OVER! Press R to restart.")

    def _update(self):
        if self.paused or self.game_over:
            return
        self.direction = self.next_direction
        head = self.snake[0]
        new_head = (head[0] + self.direction[0],
                    head[1] + self.direction[1],
                    head[2] + self.direction[2])
        # Wrap around world (optional)
        new_head = (new_head[0] % self.size,
                    new_head[1] % self.size,
                    new_head[2] % self.size)
        # Check collision with self
        if new_head in self.snake:
            self.game_over = True
            if self.score > self.high_score:
                self.high_score = self.score
            return
        self.snake.appendleft(new_head)
        if new_head == self.food:
            self.score += 1
            self.food = self._spawn_food()
            self.speed = max(0.08, self.speed - 0.01)
        else:
            self.snake.pop()

    def run(self):
        # Input thread
        def input_loop():
            while self.running:
                try:
                    ch = sys.stdin.read(1)
                    if ch == ' ':
                        self.paused = not self.paused
                    elif ch == 'r' or ch == 'R':
                        self.__init__(self.size)
                    elif ch == '\x1b' and not self.paused and not self.game_over:
                        # Arrow keys: read next two chars
                        c = sys.stdin.read(2)
                        if c == '[A': self.next_direction = (0, 0, 1)
                        elif c == '[B': self.next_direction = (0, 0, -1)
                        elif c == '[D': self.next_direction = (-1, 0, 0)
                        elif c == '[C': self.next_direction = (1, 0, 0)
                    elif ch == 'w' or ch == 'W':
                        self.next_direction = (0, 0, 1)
                    elif ch == 's' or ch == 'S':
                        self.next_direction = (0, 0, -1)
                    elif ch == 'a' or ch == 'A':
                        self.next_direction = (-1, 0, 0)
                    elif ch == 'd' or ch == 'D':
                        self.next_direction = (1, 0, 0)
                    elif ch == 'q' or ch == 'Q':
                        self.next_direction = (0, 1, 0)
                    elif ch == 'e' or ch == 'E':
                        self.next_direction = (0, -1, 0)
                    elif ch == '\x1b':  # Esc key
                        self.running = False
                except:
                    pass
        threading.Thread(target=input_loop, daemon=True).start()
        while self.running and not self.game_over:
            self._update()
            self._render()
            time.sleep(self.speed)
        if self.game_over:
            self._render()
            while self.running:
                ch = sys.stdin.read(1)
                if ch == 'r' or ch == 'R':
                    self.__init__(self.size)
                    self.run()
                    return
                elif ch == '\x1b':
                    break

if __name__ == "__main__":
    game = Snake3D()
    game.run()
