// Generated by CoffeeScript 1.6.2
(function() {
  $.ajax({
    url: "/back/retrieve",
    type: "GET",
    dataType: "json",
    cache: false
  }).done(function(resp) {
    if ((resp.error != null)) {
      return $.gritter.add({
        title: "error",
        text: resp.error,
        time: 3000
      });
    } else if (resp.message && (resp.message != null)) {
      if (resp.image && (resp.image != null)) {
        $("#image").attr("src", resp.image);
      }
      return $("#message").get(0).innerHTML = resp.message;
    }
  }).fail(function() {
    return $.gritter.add({
      title: "error",
      text: "something went wrong. could not load any of the entries.",
      time: 3000
    });
  });

  $("#submit-something").get(0).onclick = function() {
    $("#submit-dialog").show();
    return $("#slander-message").focus();
  };

  $("#chicken-out").get(0).onclick = function() {
    return $("#submit-dialog").hide();
  };

  $("#submit-slander").get(0).onclick = function() {
    $.ajax({
      url: "/back/submit",
      dataType: "json",
      data: {
        message: $("#slander-message").val(),
        image: $("#slander-image").val()
      },
      type: "POST"
    }).done(function(resp) {
      if ((resp.error != null)) {
        return $.gritter.add({
          title: "error",
          text: resp.error,
          time: 3000
        });
      } else if ((resp.success != null)) {
        return $.gritter.add({
          title: "success",
          text: resp.success,
          time: 2000
        });
      }
    }).fail(function() {
      return $.gritter.add({
        title: "error",
        text: "something went wrong. disliking simon more is not possible at this moment.",
        time: 3000
      });
    });
    $("#slander-message").val("");
    $("#slander-image").val("");
    return $("#submit-dialog").hide();
  };

}).call(this);
