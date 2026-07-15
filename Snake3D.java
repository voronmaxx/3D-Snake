// Snake3D.java
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

public class Snake3D extends JPanel implements KeyListener {
    private static final int SIZE = 8;
    private List<Point3D> snake = new ArrayList<>();
    private Point3D dir = new Point3D(0, 0, 1);
    private Point3D nextDir = new Point3D(0, 0, 1);
    private Point3D food;
    private int score = 0, high = 0;
    private int speed = 300;
    private boolean gameOver = false, paused = false;
    private Timer timer;

    static class Point3D {
        int x, y, z;
        Point3D(int x, int y, int z) { this.x = x; this.y = y; this.z = z; }
        @Override public boolean equals(Object o) {
            if (!(o instanceof Point3D)) return false;
            Point3D p = (Point3D) o;
            return x == p.x && y == p.y && z == p.z;
        }
        @Override public int hashCode() { return x + y * 31 + z * 37; }
    }

    public Snake3D() {
        setPreferredSize(new Dimension(600, 600));
        setFocusable(true);
        addKeyListener(this);
        int c = SIZE / 2;
        snake.add(new Point3D(c, c, c));
        spawnFood();
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override public void run() { update(); repaint(); }
        }, 0, speed);
    }

    private void spawnFood() {
        while (true) {
            Point3D p = new Point3D((int)(Math.random()*SIZE), (int)(Math.random()*SIZE), (int)(Math.random()*SIZE));
            if (!snake.contains(p)) { food = p; break; }
        }
    }

    private boolean contains(Point3D p) {
        return snake.contains(p);
    }

    private void update() {
        if (paused || gameOver) return;
        dir = nextDir;
        Point3D head = snake.get(0);
        Point3D newHead = new Point3D(
            (head.x + dir.x + SIZE) % SIZE,
            (head.y + dir.y + SIZE) % SIZE,
            (head.z + dir.z + SIZE) % SIZE
        );
        if (contains(newHead)) {
            gameOver = true;
            if (score > high) high = score;
            return;
        }
        snake.add(0, newHead);
        if (newHead.equals(food)) {
            score++;
            spawnFood();
            speed = Math.max(80, speed - 10);
            timer.cancel();
            timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override public void run() { update(); repaint(); }
            }, 0, speed);
        } else {
            snake.remove(snake.size() - 1);
        }
    }

    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        g.setColor(Color.BLACK);
        g.fillRect(0, 0, 600, 600);
        g.setColor(Color.WHITE);
        g.drawString("🐍 3D SNAKE   Score: "+score+"   High: "+high+"   Speed: "+(speed/1000.0), 20, 30);
        g.drawString("Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit", 20, 50);
        int cellSize = 20;
        int offset = 100;
        // Render grid
        for (int y = SIZE-1; y >= 0; y--) {
            for (int z = 0; z < SIZE; z++) {
                for (int x = 0; x < SIZE; x++) {
                    Point3D p = new Point3D(x, y, z);
                    char ch = '.';
                    if (snake.contains(p)) ch = 'o';
                    if (snake.get(0).equals(p)) ch = 'O';
                    if (food.equals(p)) ch = '★';
                    g.drawString(String.valueOf(ch), offset + (x-z)*10, offset + (x+z)*5 + y*10);
                }
            }
        }
        if (paused) { g.setColor(Color.YELLOW); g.drawString("PAUSED", 250, 400); }
        if (gameOver) { g.setColor(Color.RED); g.drawString("GAME OVER", 250, 400); }
    }

    @Override public void keyPressed(KeyEvent e) {
        int key = e.getKeyCode();
        if (key == KeyEvent.VK_SPACE) { paused = !paused; return; }
        if (key == KeyEvent.VK_R && gameOver) {
            int c = SIZE / 2;
            snake.clear();
            snake.add(new Point3D(c, c, c));
            dir = new Point3D(0, 0, 1);
            nextDir = new Point3D(0, 0, 1);
            score = 0;
            speed = 300;
            gameOver = false;
            spawnFood();
            timer.cancel();
            timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override public void run() { update(); repaint(); }
            }, 0, speed);
            return;
        }
        if (paused || gameOver) return;
        if (key == KeyEvent.VK_W || key == KeyEvent.VK_UP) nextDir = new Point3D(0, 0, 1);
        else if (key == KeyEvent.VK_S || key == KeyEvent.VK_DOWN) nextDir = new Point3D(0, 0, -1);
        else if (key == KeyEvent.VK_A || key == KeyEvent.VK_LEFT) nextDir = new Point3D(-1, 0, 0);
        else if (key == KeyEvent.VK_D || key == KeyEvent.VK_RIGHT) nextDir = new Point3D(1, 0, 0);
        else if (key == KeyEvent.VK_Q) nextDir = new Point3D(0, 1, 0);
        else if (key == KeyEvent.VK_E) nextDir = new Point3D(0, -1, 0);
        else if (key == KeyEvent.VK_ESCAPE) System.exit(0);
    }
    @Override public void keyReleased(KeyEvent e) {}
    @Override public void keyTyped(KeyEvent e) {}

    public static void main(String[] args) {
        JFrame frame = new JFrame("3D Snake");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setResizable(false);
        frame.add(new Snake3D());
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }
}
