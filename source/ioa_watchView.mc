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

        if (minutesUntilLunch >= 60) {
            minutesUntilLunch -= 60;
            hoursUntilLunch += 1;
        }

        if (hoursUntilLunch < 0) {
            hoursUntilLunch += 24;
        }

        // Time until tea (15:30 weekdays)
        var hoursUntilTea = (24 - (clockTime.hour - 15 )) % 24 - 1;
        var minutesUntilTea = 90 - clockTime.min;

        if (minutesUntilTea >= 60) {
            hoursUntilTea += 1;
            minutesUntilTea -= 60;
        }

        if (hoursUntilTea < 0) {
            hoursUntilTea += 24;
        }

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekday = today.day_of_week;

        var weekdayString = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][weekday - 1];

        var dateString = Lang.format("$1$ $2$", [weekdayString, today.day.format("%02d")]);
        var dateView = View.findDrawableById("DateLabel") as Text;

        dateView.setText(dateString);

        // Check if it is currently coffee/lunch/tea time
        var coffee_lunch_tea = false;

        var announceString = "";
        var TimeUntilString = "";
        var coffeeString = "";
        var lunchString = "";
        var TeaString = "";

        if ((hoursUntilCoffee == 23 and minutesUntilCoffee > 30) or (hoursUntilCoffee == 24 and minutesUntilCoffee == 0)) {
            if ((weekday != 1) and (weekday != 7)) {
                announceString = "Coffee Time!";
                coffee_lunch_tea = true;
            }
        }

        if ((hoursUntilLunch == 23 and minutesUntilLunch > 0) or (hoursUntilLunch == 0 and minutesUntilLunch == 0)) {
            if ((weekday != 1) and (weekday != 7)) {
                announceString = "Lunch Time!";
                coffee_lunch_tea = true;
            }
        }

        if ((hoursUntilTea == 23 and minutesUntilTea > 30) or (hoursUntilTea == 0 and minutesUntilTea == 0)) {
            if ((weekday != 1) and (weekday != 7)) {
                announceString = "Tea Time!";
                coffee_lunch_tea = true;
            }
        }


        if (weekday == 6) {
            // Friday
            if (hoursUntilCoffee >= 11) {
                hoursUntilCoffee += 48;

                if (hoursUntilLunch >= lunchHour) {
                    hoursUntilLunch += 48;

                    if (hoursUntilTea >= 15) {
                        hoursUntilTea += 48;
                    }
                }
            }
        }

        if (weekday == 7) {
            // Saturday
            if ((hoursUntilCoffee + minutesUntilCoffee/60 <= 11) and clockTime.hour < 12) {
                hoursUntilCoffee += 48;
            } else {
                hoursUntilCoffee += 24;
            }
            
            if (hoursUntilLunch + minutesUntilLunch/60 <= lunchHour) {
                hoursUntilLunch += 48;
            } else {
                hoursUntilLunch += 24;
            }
            
            if (hoursUntilTea + minutesUntilTea/60 <= 15) {
                hoursUntilTea += 48;
            } else {
                hoursUntilTea += 24;
            }
            
        }

        if (weekday == 1) {
            // Sunday
            if ((hoursUntilCoffee + minutesUntilCoffee/60 <= 11) and clockTime.hour < 12) {
                hoursUntilCoffee += 24;
            }
            
            if (hoursUntilLunch + minutesUntilLunch/60 <= lunchHour) {
                hoursUntilLunch += 24;
            }
            
            if (hoursUntilTea + minutesUntilTea/60 <= 15) {
                hoursUntilTea += 24;
            }
        }
        
        // Defaults of strings
        var announceView = View.findDrawableById("AnnounceLabel") as Text;
        var coffeeView = View.findDrawableById("CoffeeTimeLabel") as Text;
        var TeaView = View.findDrawableById("TeaTimeLabel") as Text;
        var lunchView = View.findDrawableById("LunchTimeLabel") as Text;
        var TimeUntilView = View.findDrawableById("TimeUntilLabel") as Text;

        if (!coffee_lunch_tea) {
            coffeeString = "Coffee: " + Lang.format("$1$h $2$m", [hoursUntilCoffee.format("%02d"), minutesUntilCoffee.format("%02d")]);   
            lunchString = "Lunch: " + Lang.format("$1$h $2$m", [hoursUntilLunch.format("%02d"), minutesUntilLunch.format("%02d")]);        
            TeaString = "Tea: " + Lang.format("$1$h $2$m", [hoursUntilTea.format("%02d"), minutesUntilTea.format("%02d")]);          
            TimeUntilString = "Time Until...";         
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
