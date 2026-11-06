// set up an HTTP server off port 3000
const express = require("express");
const app = express();
const port = 3000;

// set up mysql connections using the modern 'mysql2/promise' driver
const mysql = require('mysql2/promise');

// import the pool
const pool = require('./mysql');

// receiving user input using /get route and async function
app.get("/", async (req, res) => {
    const format = req.query.format || "json";

// columns the user is allowed to search by (must match your table's column names)
    const SEARCHABLE = ["book_id", "title", "author", "category", "price"];

// build the WHERE clause from whichever parameters were supplied
    const conditions = [];
    const params = [];
    for (const column of SEARCHABLE)
        if (req.query[column]) {
            conditions.push(`${column} = ?`); // column name comes from the whitelist
            params.push(req.query[column]);   // value is passed as a parameter
        }

// input validation: at least one search field is required
    if (conditions.length === 0)
        return res.status(400).send("Error: Please provide a search parameter in the URL, e.g. ?author=George Orwell");

    const sqlQuery = "SELECT * FROM HW5new.books WHERE " + conditions.join(" AND ");
    try {
        // execute the query using pool.execute()
        const [results, fields] = await pool.execute(sqlQuery, params);
        console.log(`Executed query: ${sqlQuery} with category ${params}`);

        // check for formatting request
        if (format == "text"){
            let html = `<h1>Search Results</h1>`;
            results.forEach(book => {
                html += `
                <div>
                    <h2>Title: ${book.title}</h2>
                    <p>Book ID: ${book.bookid}</p>
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
                <h2>Title: ${book.title}</h2>
                <p>Book ID: ${book.bookid}</p>
                <p>Author: ${book.author}</p>
                <p>Category: ${book.category}</p>
                <p>Price: $ ${book.price}</p>
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
