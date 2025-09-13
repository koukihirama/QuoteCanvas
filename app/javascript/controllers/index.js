import { application } from "./application";

import BookSearchController  from "./book_search_controller";
import OnboardingController  from "./onboarding_controller";
import ColorPickerController from "./color_picker_controller";
import HelloController       from "./hello_controller";
import LashController        from "./lash_controller";
import WelcomeController     from "./welcome_controller";
import LogFormController from "./log_form_controller";
import FlashController from "./flash_controller"

application.register("book-search",  BookSearchController);
application.register("onboarding",   OnboardingController);
application.register("color-picker",  ColorPickerController);
application.register("hello",        HelloController);
application.register("lash",         LashController);
application.register("welcome",      WelcomeController);
application.register("log-form", LogFormController);
application.register("flash", FlashController)

// 余計な Application.start() や window.Stimulus の代入は不要
export {};