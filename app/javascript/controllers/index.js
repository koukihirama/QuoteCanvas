import { application } from "./application"

import BookSearchController from "./book_search_controller"
application.register("book-search", BookSearchController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import LashController from "./lash_controller"
application.register("lash", LashController)

import WelcomeController from "./welcome_controller"
application.register("welcome", WelcomeController)

import OnboardingController from "./onboarding_controller";
application.register("onboarding", OnboardingController);
