const express = require('express');
const cors = require('cors'); // Import the CORS middleware
const app = express();
const port = 3000;

app.use(cors()); // Enable CORS for all routes
app.use(express.json()); // Parse JSON requests

// In-memory task storage
let tasks = [];

// Endpoint to add a task
app.post('/api/addTask', (req, res) => {
    const { task } = req.body;
    if (task) {
        tasks.push(task); // Add the task to the array
        res.status(200).json({ message: 'Task added successfully' });
    } else {
        res.status(400).json({ message: 'Task cannot be empty' });
    }
});

// Endpoint to retrieve all tasks
app.get('/api/getTasks', (req, res) => {
    res.status(200).json(tasks);
});

// Start the server
app.listen(port, () => {
    console.log(`Backend API running on http://localhost:${port}`);
});
