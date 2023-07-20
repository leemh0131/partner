


;(function($) {
    "use strict";
    
    var cronInputs={
        period: '<div class="cron-select-period"><label></label><select class="cron-period-select"></select></div>',
        startTime: '<div class="cron-input cron-start-time">시작 시간 <select class="cron-clock-hour"></select>:<select class="cron-clock-minute"></select></div>',
        container: '<div class="cron-input"></div>',
        minutes: {
            tag: 'cron-minutes',
            inputs: [ '<p>매 <select class="cron-minutes-select"></select> 분</p>' ]
        },
        hourly: {
            tag: 'cron-hourly',
            inputs: [ '<p><input type="radio" name="hourlyType" value="every"> 매일 <select class="cron-hourly-select"></select> 시간 마다</p>',
                '<p><input type="radio" name="hourlyType" value="clock"> 매일 특정시간 <select class="cron-hourly-hour"></select>:<select class="cron-hourly-minute"></select></p>']
        },
        daily: {
            tag: 'cron-daily',
            inputs: [ '<p><input type="radio" name="dailyType" value="every"> <select class="cron-daily-select"></select> 일 마다</p>',
                '<p><input type="radio" name="dailyType" value="clock"> 매일 </p>']
        },
        weekly: {
            tag: 'cron-weekly',
            inputs: [ '<p><input type="checkbox" name="dayOfWeekMon"> 월요일  <input type="checkbox" name="dayOfWeekTue"> 화요일  '+
                '<input type="checkbox" name="dayOfWeekWed"> 수요일  <input type="checkbox" name="dayOfWeekThu"> 목요일</p>',
                '<p><input type="checkbox" name="dayOfWeekFri"> 금요일  <input type="checkbox" name="dayOfWeekSat"> 토요일  '+
                '<input type="checkbox" name="dayOfWeekSun"> 일요일</p>' ]
        },
        monthly: {
            tag: 'cron-monthly',
            inputs: [ '<p><input type="radio" name="monthlyType" value="byDay"> <select class="cron-monthly-month"></select> 월 <select class="cron-monthly-day"></select> 일   </p>',
                '<p><input type="radio" name="monthlyType" value="byWeek"> 특정기간 <select class="cron-monthly-month-by-week"></select> 월 <select class="cron-monthly-nth-day"></select> 의' +
                '<select class="cron-monthly-day-of-week"></select>  </p>']
        },
        yearly: {
            tag: 'cron-yearly',
            inputs: [ '<p><input type="radio" name="yearlyType" value="byDay"> <select class="cron-yearly-month"></select> <select class="cron-yearly-day"></select></p>',
                '<p><input type="radio" name="yearlyType" value="byWeek"> 특정기간 <select class="cron-yearly-month-by-week"></select>' +
                '<select class="cron-yearly-nth-day"></select> 의 <select class="cron-yearly-day-of-week"></select> </p> ']
        }
    };

    var periodOpts=arrayToOptions(["분", "시간", "매일", "매주", "매달", "매년"]);
    var minuteOpts=rangeToOptions(1, 60);
    var hourOpts=rangeToOptions(1, 24);
    var dayOpts=rangeToOptions(1, 100);
    var minuteClockOpts=rangeToOptions(0, 59, true);
    var hourClockOpts=rangeToOptions(0, 23, true);
    var dayInMonthOpts=rangeToOptions(1, 31);
    var monthOpts=arrayToOptions(["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"],
        [1,2,3,4,5,6,7,8,9,10,11,12]);
    var monthNumOpts=rangeToOptions(1, 12);
    var nthWeekOpts=arrayToOptions(["첫번째", "두번째", "세번째", "네번째"], [1,2,3,4]);
    var dayOfWeekOpts=arrayToOptions(["월요일","화요일","수요일","목요일","금요일","토요일", "일요일"], ["MON","TUE","WED","THU","FRI","SAT", "SUN"]);


    // Convert an array of values to options to append to select input
    function arrayToOptions(opts, values) {
        var inputOpts='';
        for (var i = 0; i < opts.length; i++) {
            var value=opts[i];
            if(values!=null) value=values[i];
            inputOpts += "<option value='"+value+"'>" + opts[i] + "</option>\n";

        }
        return inputOpts;
    }

    // Convert an integer range to options to append to select input
    function rangeToOptions(start, end, isClock) {
        var inputOpts='', label;
        for (var i = start; i <= end; i++) {
            if(isClock && i < 10) label = "0" + i;
            else label = i;
            inputOpts += "<option value='"+i+"'>" + label + "</option>\n";
        }
        return inputOpts;
    }

    // Add input elements to UI as defined in cronInputs
    function addInputElements($baseEl, inputObj, onFinish) {
        $(cronInputs.container).addClass(inputObj.tag).appendTo($baseEl);
        $baseEl.children("."+inputObj.tag).append(inputObj.inputs);
        if(typeof onFinish === "function") onFinish();
    }

    var eventHandlers={
        periodSelect: function() {
            var period=($(this).val());
            var $selector=$(this).parent();
            $selector.siblings('div.cron-input').hide();
            $selector.siblings().find("select option").removeAttr("selected");
            $selector.siblings().find("select option:first").attr("selected", "selected");
            $selector.siblings('div.cron-start-time').show();
            $selector.siblings('div.cron-start-time').children("select.cron-clock-hour").val('12');
            switch(period) {
                case '분':
                    $selector.siblings('div.cron-minutes')
                        .show()
                        .find("select.cron-minutes-select").val('1');
                    $selector.siblings('div.cron-start-time').hide();
                    break;
                case '시간':
                    var $hourlyEl=$selector.siblings('div.cron-hourly');
                    $hourlyEl.show()
                        .find("input[name=hourlyType][value=every]").prop('checked', true);
                    $hourlyEl.find("select.cron-hourly-hour").val('12');
                    $selector.siblings('div.cron-start-time').hide();
                    break;
                case '매일':
                    var $dailyEl=$selector.siblings('div.cron-daily');
                    $dailyEl.show()
                        .find("input[name=dailyType][value=every]").prop('checked', true);
                    break;
                case '매주':
                    $selector.siblings('div.cron-weekly')
                        .show()
                        .find("input[type=checkbox]").prop('checked', false);
                    break;
                case '매달':
                    var $monthlyEl=$selector.siblings('div.cron-monthly');
                    $monthlyEl.show()
                        .find("input[name=monthlyType][value=byDay]").prop('checked', true);
                    break;
                case '매년':
                    var $yearlyEl=$selector.siblings('div.cron-yearly');
                    $yearlyEl.show()
                        .find("input[name=yearlyType][value=byDay]").prop('checked', true);
                    break;
            }
        }
    };

    // Public functions
    $.cronBuilder = function(el, options) {
        var base = this;

        // Access to jQuery and DOM versions of element
        base.$el=$(el);
        base.el=el;

        // Reverse reference to the DOM object
        base.$el.data('cronBuilder', base);

        // Initialization
        base.init = function() {
            base.options = $.extend({},$.cronBuilder.defaultOptions, options);


            base.$el.append(cronInputs.period);
            base.$el.find("div.cron-select-period label").text(base.options.selectorLabel);
            base.$el.find("select.cron-period-select")
                .append(periodOpts)
                .bind("change", eventHandlers.periodSelect);

            addInputElements(base.$el, cronInputs.minutes, function() {
                base.$el.find("select.cron-minutes-select").append(minuteOpts);
            });

            addInputElements(base.$el, cronInputs.hourly, function() {
                base.$el.find("select.cron-hourly-select").append(hourOpts);
                base.$el.find("select.cron-hourly-hour").append(hourClockOpts);
                base.$el.find("select.cron-hourly-minute").append(minuteClockOpts);
            });

            addInputElements(base.$el, cronInputs.daily, function() {
                base.$el.find("select.cron-daily-select").append(dayOpts);
            });

            addInputElements(base.$el, cronInputs.weekly);

            addInputElements(base.$el, cronInputs.monthly, function() {
                base.$el.find("select.cron-monthly-day").append(dayInMonthOpts);
                base.$el.find("select.cron-monthly-month").append(monthNumOpts);
                base.$el.find("select.cron-monthly-nth-day").append(nthWeekOpts);
                base.$el.find("select.cron-monthly-day-of-week").append(dayOfWeekOpts);
                base.$el.find("select.cron-monthly-month-by-week").append(monthNumOpts);
            });

            addInputElements(base.$el, cronInputs.yearly, function() {
                base.$el.find("select.cron-yearly-month").append(monthOpts);
                base.$el.find("select.cron-yearly-day").append(dayInMonthOpts);
                base.$el.find("select.cron-yearly-nth-day").append(nthWeekOpts);
                base.$el.find("select.cron-yearly-day-of-week").append(dayOfWeekOpts);
                base.$el.find("select.cron-yearly-month-by-week").append(monthOpts);
            });


            base.$el.append(cronInputs.startTime);
            base.$el.find("select.cron-clock-hour").append(hourClockOpts);
            base.$el.find("select.cron-clock-minute").append(minuteClockOpts);

            if(typeof base.options.onChange === "function") {
                base.$el.find("select, input").change(function() {
                    base.options.onChange(base.getExpression());
                });
            }

            base.$el.find("select.cron-period-select")
                .triggerHandler("change");

        }

        base.getExpression = function() {
            //var b = c.data("block");
            var sec = 0; // ignoring seconds by default
            var year = "*"; // every year by default
            var dow = "?";
            var month ="*", dom = "*";
            var min=base.$el.find("select.cron-clock-minute").val();
            var hour=base.$el.find("select.cron-clock-hour").val();
            var period = base.$el.find("select.cron-period-select").val();
            switch (period) {
                case '분':
                    var $selector=base.$el.find("div.cron-minutes");
                    var nmin=$selector.find("select.cron-minutes-select").val();
                	if(nmin > 1) min ="0/"+nmin;
                	else min="*";
                	hour="*";
                    break;

                case '시간':
                    var $selector=base.$el.find("div.cron-hourly");
                    if($selector.find("input[name=hourlyType][value=every]").is(":checked")){
                        min=0;
                        hour="*";
                        var nhour=$selector.find("select.cron-hourly-select").val();
                    	if(nhour > 1) hour ="0/"+nhour;
                    } else {
                        min=$selector.find("select.cron-hourly-minute").val();
                        hour=$selector.find("select.cron-hourly-hour").val();
                    }
                    break;

                case '매일':
                    var $selector=base.$el.find("div.cron-daily");
                    if($selector.find("input[name=dailyType][value=every]").is(":checked")){
                        var ndom=$selector.find("select.cron-daily-select").val();
                        if(ndom > 1) dom ="1/"+ndom;
                    } else {
                        dom="?";
                        dow="MON-FRI";
                    }
                    break;

                case '매주':
                    var $selector=base.$el.find("div.cron-weekly");
                    var ndow=[];
                    if($selector.find("input[name=dayOfWeekMon]").is(":checked"))
                        ndow.push("MON");
                    if($selector.find("input[name=dayOfWeekTue]").is(":checked"))
                        ndow.push("TUE");
                    if($selector.find("input[name=dayOfWeekWed]").is(":checked"))
                        ndow.push("WED");
                    if($selector.find("input[name=dayOfWeekThu]").is(":checked"))
                        ndow.push("THU");
                    if($selector.find("input[name=dayOfWeekFri]").is(":checked"))
                        ndow.push("FRI");
                    if($selector.find("input[name=dayOfWeekSat]").is(":checked"))
                        ndow.push("SAT");
                    if($selector.find("input[name=dayOfWeekSun]").is(":checked"))
                        ndow.push("SUN");
                    dow="*";
                    dom="?";
                    if(ndow.length < 7 && ndow.length > 0) dow=ndow.join(",");
                    break;

                case '매달':
                    var $selector=base.$el.find("div.cron-monthly");
                    var nmonth;
                    if($selector.find("input[name=monthlyType][value=byDay]").is(":checked")){
                        month="*";
                        nmonth=$selector.find("select.cron-monthly-month").val();
                        dom=$selector.find("select.cron-monthly-day").val();
                        dow="?";
                    } else {
                        dow=$selector.find("select.cron-monthly-day-of-week").val()
                            +"#"+$selector.find("select.cron-monthly-nth-day").val();
                        nmonth=$selector.find("select.cron-monthly-month-by-week").val();
                        dom="?";
                    }
                    if(nmonth > 1) month ="1/"+nmonth;
                    break;

                case '매년':
                    var $selector=base.$el.find("div.cron-yearly");
                    if($selector.find("input[name=yearlyType][value=byDay]").is(":checked")){
                        dom=$selector.find("select.cron-yearly-day").val();
                        month=$selector.find("select.cron-yearly-month").val();
                        dow="?";
                    } else {
                        dow=$selector.find("select.cron-yearly-day-of-week").val()
                            +"#"+$selector.find("select.cron-yearly-nth-day").val();
                        month=$selector.find("select.cron-yearly-month-by-week").val();
                        dom="?";
                    }
                    break;
    
                default:
                    break;
            }
            return [sec, min, hour, dom, month, dow, year].join(" ");            
        };
        
        base.init();
    };
    
    // Plugin default options
    $.cronBuilder.defaultOptions = {
        selectorLabel: "선택 기간 : "
        
    };    
 
    // Plugin definition 
    $.fn.cronBuilder = function(options) {
        return this.each(function(){
            (new $.cronBuilder(this, options));
        });
    };
 
}( jQuery ));