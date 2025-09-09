import { application } from "./application"

import BookSearchController from "./book_search_controller"
application.register("book-search", BookSearchController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)
