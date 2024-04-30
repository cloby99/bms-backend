import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerinax/postgresql;

configurable string host = "localhost";
configurable string username = "postgres";
configurable string password = "1111";
configurable string database = "bookdb";
configurable int port = 5432;

postgresql:Client dbClient = check new (host, username, password, database, port);

type Book record {|

    readonly int id;

    @sql:Column {name : "title"}
    string title;

    @sql:Column {name: "author"}
    string author;

    @sql:Column {name: "genre"}
    string genre;

    @sql:Column {name: "language"}
    string language;

    @sql:Column {name: "availability"}
    boolean availability;
|};

type NewBook record {|
    string title;
    string author;
    string genre;
    string language;
    boolean availability;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type BookNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

@http:ServiceConfig{
    cors: {
        allowOrigins: ["*"]
    }
}
service / on new http:Listener(8080){


    resource function get books() returns Book[]|error {
        stream<Book, sql:Error?> bookStream = dbClient->query(`SELECT * FROM bookstore`);
        return from var book in bookStream
            select book;
    }

    resource function get book/[int id]() returns Book|BookNotFound|error{
        Book|sql:Error book = dbClient->queryRow(`SELECT * FROM bookstore WHERE id = ${id}`);

        if book is sql:NoRowsError {
            BookNotFound bookNotFound = {
                body: {
                    message: string `id ${id}`,
                    details: string `book/${id}`,
                    timeStamp: time:utcNow()
                }
            };
            return bookNotFound;
        }
        return book;
    }

    resource function delete book/[int id]() returns http:NoContent|error{
        _ = check dbClient->execute(`DELETE FROM bookstore WHERE id = ${id};`);
        return http:NO_CONTENT;
    }

    resource function post book(NewBook newBook) returns http:Created|error{
        sql:ParameterizedQuery query = `INSERT INTO bookstore(title, author, genre, language, availability) VALUES 
                                                            (${newBook.title}, ${newBook.author}, ${newBook.genre}, ${newBook.language}, ${newBook.availability})`;

        _ = check dbClient->execute(query);
        return http:CREATED;
    }

    resource function put book/[int id](NewBook newBook) returns http:Response|error {
        
        sql:ParameterizedQuery query =  `UPDATE bookstore SET title = ${newBook.title},
                                                                author = ${newBook.author},
                                                                genre = ${newBook.genre},
                                                                language = ${newBook.language},
                                                                availability = ${newBook.availability}
                                                                WHERE id = ${id}
                                                                `;

        sql:ExecutionResult|sql:Error result = dbClient->execute(query);

        http:Response response = new;
        if result is sql:ExecutionResult {
            if result.affectedRowCount > 0 {
                response.statusCode = 202; 
                response.setPayload("Book updated successfully");
                response.setHeader("Access-Control-Allow-Origin", "*");
                return response;
            } else {
                return error("No Book found with the id: " + id.toString());
            }
        } else {
            return error("Database error: " + result.message());
        } 

    }

}