$(function () {
    function display(bool) {
        if (bool) {
            $("#container").show();
        } else {
            $("#container").hide();
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
    })
    // if the person uses the escape key, it will exit the resource
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('http://scb_nuispz/exit', JSON.stringify({}));
            return
        }
    };
    $("#close").click(function () {
        $.post('http://scb_nuispz/exit', JSON.stringify({}));
        return
    })

    $("#datspz").click(function () {
        $.post('http://scb_nuispz/datspz', JSON.stringify({}));
        return
    })

    $("#sundatspz").click(function () {
        $.post('http://scb_nuispz/sundatspz', JSON.stringify({}));
        return
    })
})