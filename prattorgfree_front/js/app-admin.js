// Generated by CoffeeScript 1.6.2
(function() {
  var load_messages;

  load_messages = function() {
    return $.ajax({
      url: "/back/admin",
      type: "GET",
      dataType: "json",
      cache: false,
      data: {
        password: $("#password").val()
      }
    }).done(function(resp) {
      var clone, message, _i, _len, _ref, _results;

      if ((resp.error != null)) {
        return $.gritter.add({
          title: "error",
          text: resp.error,
          time: 3000
        });
      } else if (resp.messages && (resp.messages != null)) {
        _ref = resp.messages;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          message = _ref[_i];
          clone = $("#item-template").get(0).cloneNode(true);
          $(clone).children("h4").each(function() {
            return $(this).get(0).innerHTML = message.message;
          });
          if (message.image && (message.image != null)) {
            $(clone).children("a").each(function() {
              $(this).get(0).href = message.image;
              return $(this).removeClass("hide");
            });
          }
          $(clone).removeAttr("id");
          $(clone).removeClass("hide");
          _results.push($("#slanderous-messages").get(0).appendChild(clone));
        }
        return _results;
      }
    }).fail(function() {
      return $.gritter.add({
        title: "error",
        text: "something went wrong. could not load any of the entries.",
        time: 3000
      });
    });
  };

  $("#load-messages").on("click", function() {
    if ($("#slanderous-messages").children("div").length === 1) {
      return load_messages();
    }
  });

}).call(this);
