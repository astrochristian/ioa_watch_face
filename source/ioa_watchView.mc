import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

class ioa_watchView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var mainView = View.findDrawableById("MainTimeLabel") as Text;

        mainView.setText(timeString);

        // Time until coffee (11:00 weekdays)
        var hoursUntilCoffee = (24 - (clockTime.hour - 11)) % 24 - 1;

        if (hoursUntilCoffee < 0) {
            hoursUntilCoffee += 24;
        }

        var minutesUntilCoffee = 60 - clockTime.min;

        if (minutesUntilCoffee == 60) {
            minutesUntilCoffee = 0;
            hoursUntilCoffee += 1;
        }

        // Time until lunch (13:00 weekdays by default)
        var lunchHour = Application.getApp().getProperty("lunchHour");
        var lunchMinute = Application.getApp().getProperty("lunchMin");

        var hoursUntilLunch = (24 - (clockTime.hour - lunchHour)) % 24 - 1;
        var minutesUntilLunch = 60 + lunchMinute - clockTime.min;

        if (hoursUntilLunch < 0) {
            hoursUntilLunch += 24;
        }

        if (minutesUntilLunch >= 60) {
            minutesUntilLunch -= 60;
            hoursUntilLunch += 1;
        }

        // Time until tea (15:30 weekdays)
        var hoursUntilTea = (24 - (clockTime.hour - 15 )) % 24 - 1;
        var minutesUntilTea = 90 - clockTime.min;

        if (hoursUntilTea < 0) {
            hoursUntilTea += 24;
        }

        if (minutesUntilTea >= 60) {
            hoursUntilTea += 1;
            minutesUntilTea -= 60;
        }

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekday = today.day_of_week;

        if (weekday == 7) {
            // Saturday
            hoursUntilCoffee += 48;
            hoursUntilLunch += 48;
            hoursUntilTea += 48;
            
        }

        if (weekday == 1) {
            // Sunday
            hoursUntilCoffee += 24;
            hoursUntilLunch += 24;
            hoursUntilTea += 24;
        }
        
        // Defaults of strings
        var announceString = "";
        var announceView = View.findDrawableById("AnnounceLabel") as Text;

        var coffeeString = "Coffee: " + Lang.format("$1$h $2$m", [hoursUntilCoffee.format("%02d"), minutesUntilCoffee.format("%02d")]);
        var coffeeView = View.findDrawableById("CoffeeTimeLabel") as Text;

        var lunchString = "Lunch: " + Lang.format("$1$h $2$m", [hoursUntilLunch.format("%02d"), minutesUntilLunch.format("%02d")]);
        var lunchView = View.findDrawableById("LunchTimeLabel") as Text;

        var TeaString = "Tea: " + Lang.format("$1$h $2$m", [hoursUntilTea.format("%02d"), minutesUntilTea.format("%02d")]);
        var TeaView = View.findDrawableById("TeaTimeLabel") as Text;

        var TimeUntilString = "Time Until...";
        var TimeUntilView = View.findDrawableById("TimeUntilLabel") as Text;

        // Check if it is currently coffee/lunch/tea time
        if ((hoursUntilCoffee == 23 and minutesUntilCoffee > 30) or (hoursUntilCoffee == 24 and minutesUntilCoffee == 0)) {
            announceString = "Coffee Time!";

            TimeUntilString = "";
            coffeeString = "";
            lunchString = "";
            TeaString = "";
        }

        if ((hoursUntilLunch == 23 and minutesUntilLunch > 0) or (hoursUntilLunch == 24 and minutesUntilLunch == 0)) {
            announceString = "Lunch Time!";

            TimeUntilString = "";
            coffeeString = "";
            lunchString = "";
            TeaString = "";
        }

        if ((hoursUntilTea == 23 and minutesUntilTea > 30) or (hoursUntilTea == 24 and minutesUntilTea == 0)) {
            announceString = "Tea Time!";

            TimeUntilString = "";
            coffeeString = "";
            lunchString = "";
            TeaString = "";
        }


        // Set views
        announceView.setText(announceString);
        TimeUntilView.setText(TimeUntilString);
        coffeeView.setText(coffeeString);
        lunchView.setText(lunchString);
        TeaView.setText(TeaString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
