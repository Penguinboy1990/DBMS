// set up an HTTP server off port 3000
const express = require("express");
const app = express();
const port = 3000;

// set up mysql connections using the modern 'mysql2/promise' driver
const mysql = require('mysql2/promise');

// import the pool
const pool = require('./mysql');

// receiving user input using /get route and async function
// user should pass a category search for, e.g., /?category=dystopian
app.get("/", async (req, res) => {
    const category = req.query.category;
    const format = req.query.format || "text"; // default to text if not specified
    if (!category) // input validation: ensure the input exists
        return res.status(400).send("Error: Please provide a 'category' to search for.");

    // define the query structure with a placeholder (?)
    const sqlQuery = "SELECT * FROM HW5new.books WHERE category = ?";

    // The user's input is passed as a separate array
    const params = [category];
    try {
        // execute the query using pool.execute()
        const [results, fields] = await pool.execute(sqlQuery, params);
        console.log(`Executed query: ${sqlQuery} with category ${category}`);

        // check for formatting request
        if (format == "text"){
            let html = `<h1>Books in Database with Category: ${category}</h1>`;
            results.forEach(book => {
                html += `
                <div>
                    <h2>${book.title}</h2>
                    <p>Book ID: ${book.book_id}</p>
                    <p>Author: ${book.author}</p>
                    <p>Category: ${book.category}</p>
                    <p>Price: $ ${book.price}</p>
                </div>
                <hr>
                `;
            });
            // send the results back to the browser
            res.status(200).type('html').send(html);
        }else res.status(200).json(results);

    }catch (err) {
        // log the detailed error on the server
        console.error("Database error:", err.message);
        // Send a generic, non-revealing error to the client for security
        res.status(500).send("A database error occurred.");}
});

// receiving user input for format of results
app.get("/format", async (req,res) => {
    const format = req.query.format;
    if (format == "text"){
        let html = `<h1>Books in Database with Category: ${category}</h1>`;
        results.forEach(book => {
            html += `
            <div>
                <h2>${book.title}</h2>
                <p>Book ID: ${book.book_id}</p>
                <p>Author: ${book.author}</p>
                <p>Price: ${book.price}</p>
            </div>
            <hr>
            `;
        });
        res.type('html').send(html);
    } else res.json(results);
})

// wait indefinitely in a loop
app.listen(port, function () {
    console.log(`Server running on http://localhost:${port}`);
});
