$(document).ready(function ()
{
    var eq = "";        //выражение для вычисления
    var curNumber = ""; //позиция 
    var result = "";    //результат вычислений
    var entry = "";     //введённое выражение
    var reset = false;  //индикатор сброса состояния

    $("a").click(function () {
        $(this).css("background-color", "lightblue");
        eq = $(this).html();
        result = eval(eq);                      // вычисление введённого выражения 
        $('#result > p').html(result);          // вывод в табло результата
        eq += "=" + result;
        $('#previous > p').html(eq);            // вывод в табло результата с выражением
    });

    $("button").click(function ()
    {
        entry = $(this).attr("value");

        if (entry === "ac")
        {
            entry = 0;
            eq = 0;
            result = 0;
            curNumber = 0;
            $('#result > p').html(entry);
            $('#previous > p').html(eq);
        }
        else if (entry === "ce")
        {
            if (eq.length > 1)
            {
                eq = eq.slice(0, -1);
                $('#previous > p').html(eq);
            }
            else
            {
                eq = 0;
                $('#result > p').html(0);
            }

            $('#previous > p').html(eq);

            if (curNumber.length > 1)
            {
                curNumber = curNumber.slice(0, -1);
                $('#result > p').html(curNumber);
            }
            else
            {
                curNumber = 0;
                $('#result > p').html(0);
            }
        }
        else if (entry === "=")
        {
            result = eval(eq);                      // вычисление введённого выражения 

            $.post('/Home/Add?expression=' + eq)    // отправка выражения на сервер
                .done(function () {                                     // в случае успеха
                    //$("#expressions").append("<a>" + eq + "</a>"); //либо добавляем операцию в список DOM
                    $("#expressions").load('/Home/History');          //либо забираем историю с сервера и перезаписываем
                })
                .fail(function () {
                    alert("запись не добавляется ввиду ошибки");
                });

            $('#result > p').html(result);          // вывод в табло результата
            eq += "=" + result;
            $('#previous > p').html(eq);            // вывод в табло результата с выражением

            eq = result;
            entry = result;
            curNumber = result;
            reset = true;
        }
        else if (isNaN(entry))       //проверка на то, что ввели число
        {
            if (entry !== ".")       //проверка на вещественность
            {
                reset = false;
                if (curNumber === 0 || eq === 0)
                {
                    curNumber = 0;
                    eq = entry;
                }
                else
                {
                    curNumber = "";
                    eq += entry;
                }
                $('#previous > p').html(eq);
            }
            else if (curNumber.indexOf(".") === -1)
            {
                reset = false;
                if (curNumber === 0 || eq === 0)
                {
                    curNumber = 0.;
                    eq = 0.;
                }
                else
                {
                    curNumber += entry;
                    eq += entry;
                }
                $('#result > p').html(curNumber);
                $('#previous > p').html(eq);
            }
        }
        else
        {
            if (reset)
            {
                eq = entry;
                curNumber = entry;
                reset = false;
            }
            else
            {
                eq += entry;
                curNumber += entry;
            }
            $('#previous > p').html(eq);
            $('#result > p').html(curNumber);
        }

        if (curNumber.length > 10 || eq.length > 26)
        {
            $("#result > p").html("0");
            $("#previous > p").html("перебор с цифрами");
            curNumber = "";
            eq = "";
            result = "";
            reset = true;
        }

        if (result.indexOf(".") !== -1)
        {
            result = result.truncate();
        }
    });
});