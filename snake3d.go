// snake3d.go
package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"time"
)

const SIZE = 8

type Point struct {
	X, Y, Z int
}

type Snake struct {
	body   []Point
	dir    Point
	nextDir Point
	food   Point
	score  int
	high   int
	speed  float64
	gameOver bool
	paused bool
	running bool
}

func NewSnake() *Snake {
	s := &Snake{
		body:   make([]Point, 0),
		dir:    Point{0, 0, 1},
		nextDir: Point{0, 0, 1},
		speed:  0.3,
		running: true,
	}
	center := SIZE / 2
	s.body = append(s.body, Point{center, center, center})
	s.spawnFood()
	return s
}

func (s *Snake) spawnFood() {
	for {
		p := Point{rand.Intn(SIZE), rand.Intn(SIZE), rand.Intn(SIZE)}
		if !s.contains(p) {
			s.food = p
			break
		}
	}
}

func (s *Snake) contains(p Point) bool {
	for _, seg := range s.body {
		if seg == p {
			return true
		}
	}
	return false
}

func (s *Snake) update() {
	if s.paused || s.gameOver {
		return
	}
	s.dir = s.nextDir
	head := s.body[0]
	newHead := Point{
		(head.X + s.dir.X + SIZE) % SIZE,
		(head.Y + s.dir.Y + SIZE) % SIZE,
		(head.Z + s.dir.Z + SIZE) % SIZE,
	}
	if s.contains(newHead) {
		s.gameOver = true
		if s.score > s.high {
			s.high = s.score
		}
		return
	}
	s.body = append([]Point{newHead}, s.body...)
	if newHead == s.food {
		s.score++
		s.spawnFood()
		s.speed = max(0.08, s.speed-0.01)
	} else {
		s.body = s.body[:len(s.body)-1]
	}
}

func max(a, b float64) float64 {
	if a > b { return a }
	return b
}

func (s *Snake) render() {
	fmt.Print("\033[H\033[2J")
	fmt.Printf("🐍 3D SNAKE   Score: %d   High: %d   Speed: %.2fs\n", s.score, s.high, s.speed)
	fmt.Println("Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit")
	// Simple grid rendering (top-down slice)
	for y := SIZE - 1; y >= 0; y-- {
		for z := 0; z < SIZE; z++ {
			for x := 0; x < SIZE; x++ {
				p := Point{x, y, z}
				ch := '.'
				if s.contains(p) {
					ch = 'o'
				}
				if p == s.body[0] {
					ch = 'O'
				}
				if p == s.food {
					ch = '★'
				}
				fmt.Printf("%c ", ch)
			}
			fmt.Println()
		}
	}
	if s.paused {
		fmt.Println("\n⏸️  PAUSED")
	}
	if s.gameOver {
		fmt.Println("\n💀 GAME OVER! Press R to restart.")
	}
}

func (s *Snake) run() {
	go func() {
		reader := bufio.NewReader(os.Stdin)
		for s.running {
			ch, _ := reader.ReadByte()
			switch ch {
			case ' ':
				s.paused = !s.paused
			case 'r', 'R':
				*s = *NewSnake()
			case 'w', 'W':
				s.nextDir = Point{0, 0, 1}
			case 's', 'S':
				s.nextDir = Point{0, 0, -1}
			case 'a', 'A':
				s.nextDir = Point{-1, 0, 0}
			case 'd', 'D':
				s.nextDir = Point{1, 0, 0}
			case 'q', 'Q':
				s.nextDir = Point{0, 1, 0}
			case 'e', 'E':
				s.nextDir = Point{0, -1, 0}
			case 27: // Esc
				s.running = false
			}
		}
	}()
	for s.running && !s.gameOver {
		s.update()
		s.render()
		time.Sleep(time.Duration(s.speed * 1000) * time.Millisecond)
	}
	if s.gameOver {
		s.render()
		for s.running {
			ch, _ := bufio.NewReader(os.Stdin).ReadByte()
			if ch == 'r' || ch == 'R' {
				*s = *NewSnake()
				s.run()
				return
			}
			if ch == 27 {
				break
			}
		}
	}
}

func main() {
	rand.Seed(time.Now().UnixNano())
	snake := NewSnake()
	snake.run()
}
