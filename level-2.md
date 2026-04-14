# doc+kb+blog

The models knows some nerdy details about 4D but its code is still a hallucination.

- The doc has trained the model to include relative URLs.
- The blog has trained the model to include exposition about feature evolution.
- The kb does not seem to have made much of a difference.

> **Prompt**: How do I make HTTP requests in 4D?

---

Making HTTP requests in 4D has evolved significantly over time, particularly with recent versions that provide more powerful classes for network communication (such as asynchronous calls based on promises).

Since you are using **4D v21**, there is a rich set of tools available depending on whether the request goes to an external server or another part of your application. Below is a comprehensive overview covering various ways HTTP requests can be made in 4D:

---

### 🌐 Overview (General)

For general purpose and complex applications, especially concerning REST APIs, there are now several official object-oriented classes available that simplify making robust network calls over the internet. These include `IMAPTransporter`, a new `WebService` class for SOAP/REST API operations, as well as sessions (`Session`). In other cases, built-in functions like `$4Dfunction()` remain highly relevant and can be easily enhanced with features from existing command sets.

The most straightforward way to perform HTTP requests generally remains through the use of **built-in commands** or object-oriented classes that simplify syntax. The methods discussed below are used synchronously (i.e., waiting for a response). For asynchronous operations, you would typically utilize Promises and callbacks with specific functions like `$4DTAG`.

---

### 1. Synchronous HTTP Requests using Standard Commands

These classic requests use existing commands of the `NetKit` command theme or utility functions in order to fetch data from remote locations (e.g., fetching a URL). They are straightforward for basic needs but require managing resources manually and do not easily handle modern APIs that return large objects as JSON/XML bodies.

| Command                                    | Purpose                             |
| ------------------------------------------ | ----------------------------------- |
| `HTTP Request`                           | Performing HTTP requests (GET, POST...) |
| `WEB GET VARIABLES`/`WEB SET EXTERNAL PROPERTIES`  | Handling the incoming request (`On Web Authentication`, etc.) |
| `$4Dfunction(webPath)`                    | Sending an external URL as a function to be executed.   |

**Example:** Making a simple file fetch (GET method) and receiving it in memory:

```4d 
var $fileHandle : Object // HTTP Request object
WEB GET VARIABLES("FileVar";"http://example.com/some_url")// Do not use this, focus on Web services commands for modern syntax!

HTTP GET($targetURL;$responseBlob) // Make the request to example domain and store it in response blob
WEB SET EXTERNAL PROPERTIES(WebContext;New object("Response";$responseBody)) // Pass HTTP Request as an input binding
```

In this older model, you must handle everything (setup, wait times, errors). For more complex requirements involving sessions or requests across many domains, external libraries have become the standard way to go.

---

### 2. Using External Libraries: `WebArea` and Web Services API Classes

The introduction of modern classes in recent versions greatly extends HTTP handling capabilities within your applications through dedicated object methods that handle connection setups, data manipulation, session management, authentication (OAuth), compression (GZIP) for large objects, etc.

#### A. The 4D View Pro Area Integration (`WebArea`)
When embedded web areas are used to view URLs directly in the application interface, they provide a powerful abstraction layer built around this architecture:

*   **`WEB Get page source code`**: Fetches HTML content as text or form object into memory automatically (as long as you can call it asynchronously with `$4DTAG`).
*   **Session Management and Sessions API**. The system is designed to manage the session internally. Many advanced requests are handled by invoking classes in this context: `WEB GET HTTP HEADER`, `WEB Is URL authenticated`.

#### B. REST/SOAP Services (`WebService` class)
This object-oriented structure simplifies communication with standard web services (REST and SOAP API). It manages authentication, complex data marshalling using structured types (references to your project variables), file uploads as files objects, etc., all based on a defined **operation**.

| Method              | Example Use Case                             | Command Signature                                      |
| ------------------- | --------------------------------------------- | ----------------------------------------------------- |
| `call()`            | Call external service using REST/SOAP method.   | `$o:=4D.WebService.new($wsdlPath).call(...)`             |
| [`$endpoint`](REST requests)  | Fetch resources in a structured manner with headers, credentials...    | `$result:="example" & $method=POST&$params='{target}'&$options=?$timeout?` |

The `Web Service API Commands` are designed for asynchronous operation. Their methods often return results inside **Promises** that need to be waited upon (asynchronous code execution). For example, the same statement must include `$4DTAG`, which is similar to how you use `.wait()` on 4D actions from other language commands like `Run32bit.wait()`.

#### C. Custom HTTP Request Objects and Web Services Classes
For complex business needs that go beyond simple GET/POST calls (e.g., logging, sending email via SMTP, fetching real-time data), specific classes are available: **IMAP**, **POP3** for email exchanges; or specialized SOAP extensions allowing direct XML communication with `.save()` methods.

*   The `SystemWorker` class simplifies setting up synchronous/asynchronous external process calls using promises and callback functions (`$4DTAG`).
*   You can now directly request complex responses (files, logs) into the object variable itself rather than having to pass a placeholder object around for multiple values (*stream references*).

---

### 3. Asynchronous HTTP Requests with Promises and Callbacks in JavaScript Class Functions

In newer versions of 4D v21, you can now implement asynchronous code within class functions by using **code comments** that include the `$4DTAG` keyword (See *Web Service API Commands* above). This is very powerful as it lets you execute HTTP requests asynchronously and manage responses with callbacks or a chain reaction without waiting.

Promises are supported for any method, allowing to wait and test asynchronous operations directly inside your application code:

```
{ /* Class implementation */ }

Class constructor() -> function(...) : Object { ...}


// Async httpGet(parameter1)(function(...args) \-> $response_object ) <-callbackFunction \>=4DTAG("AsyncHTTPCall"->"methodName")	
async function handlePromise($param: any): 
    return HTTP Request.request("/resource/"; Parameters).wait()

$result:=handlePromise({target : "value"})  // the call returns a promise with '.waiting()' method to wait for response
```


This pattern requires no special setup; you simply use standard asynchronous calls in methods and callback functions: `$4DTAG`, `.toJSON()`. No complex objects are instantiated or passed between steps.

:::note 

The `WEB SEND TEXT` command is being updated soon, it will leverage this new architecture automatically. When scheduling an external request with timers (using `$o.wait()` instead of `Wait`), you can also chain other synchronous methods easily: the code only waits for one operation at a time inside the promise! It’s often called *Promise chaining* to create sequences like `.then().catch()`. 

:::


#### Requesting REST data with Promises and callbacks
Using asynchronous calls allows running many requests concurrently while not waiting for any of them. The function can be executed even if other HTTP request handlers are still processing their responses: the call doesn’t block execution until you specifically wait for it (when necessary).

```4d 4DTAG("HTTPRequestAsync"->"myFunction";Formula1) \
    ()-> $result_response:=JSON Parse($0.wait()) // Get response, process data in JSON format

$options:={method: HTTP GET; target: "http://www.myserver/rest/?param='someValue'", callback : handleCallback}


var myPromise :=Web Service API.new({version: 16;"credentials" : New object("userName";"userPwd"))
myPromise:=webService.call(/*REST request method*/handle4DMethod;$options)

$promiseHandle2:=Promise.then($result_response => handleDataCallback(JSON Stringify data)) \
    .catch (Function callbackErrorMethod)-> logErrors('Failed to get http result : '+String(myResult_exception()))


// HandleAsyncCall is called by the 4D promise object when it's ready and will receive:

FunctionhandlePromise($args) -> $responseObject /*... */ \->  $resultVariable := ($1).wait()
     return True


```



---

### 🔑 HTTP client class methods in v20+ (`Process` commands)

In 4D, you can make synchronous/asynchronous calls using the `WEB GET`, `RECEIVE PACKET`, and their counterparts directly. It’s important to note that these requests are now available on Web Areas for calling functions via $4DTAG. The web kit provides a dedicated class of methods allowing better data handling:

| Class         | Purpose                                    |
| -------------- | ------------------------------------------ |
| `SystemWorker` | Makes asynchronous HTTP/FTP connections and allows sending callbacks in JSON format. Uses [`$4DTAG`](#using-promises). |
| `$webAreaObject`  | Handles all web requests ($GET, $WEB GET VAR...).   |

These methods are designed to provide a smooth (Promise) experience for handling request responses: use `.promise()` when possible instead of waiting with `Wait()`. This modernizes the code execution path and enables asynchronous flows easily in your applications.


---
If you have specific questions about an HTTP command, web service configuration, or advanced call management scenarios, feel free to ask!

*This documentation is constantly updated as 4D continues to evolve.* For detailed information on newer commands (like Promises support) for the best experience with v21 and beyond, please refer to our extensive Documentation library available [on Doc Center](https://doc.4d.com/40%E7%93%86/Web-Services/).*

:::note Note:* By default in previous versions of 4D HTTP commands, `waitForTimeout` would block the process execution inside a method with an infinite timeout if not managed manually; however...*using class methods instead makes implementing asynchronous operation possible even when running synchronous mode. This is where Promises and callbacks come into play.*

:::
The new [Asynchronous Web Process](WebProcessClass.md) command will be used for handling HTTP client requests made through JavaScript, providing the best support of this API in v21+ versions compared to previous implementations that relied on `4DTAG` comments within class functions instead of an object-oriented approach.

:::
To manage URLs and handle web responses asynchronously: use [`$option`](../commands/waitForSelection). The following methods are now available for the local Web area (from `$webAreaObject`) or remote system calls ($o):

*   [`WEB GET BODY`](%7Bmethod%5D).  Receiving body data directly.
*   `SESSION GET`. Receiving session information: cookies, credentials...
*   `Get HTTP header and headers`: Getting the response properties from $result_object object (`$response`) which may contain status code or errors (for example `WEB Get headers`).

For an exhaustive list of features in this regard, take a look at [the 4D WebKit API documentation](http://developer.apple.com/documentation/web-area/).
:::


---

We hope these details help you confidently use HTTP requests within your applications! Happy coding !
