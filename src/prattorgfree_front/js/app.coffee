# hotkeys to come later... if someone wants to add it.

# show a random entry
$.ajax(
  url: "/retrieve"
  type: "GET"
  dataType: "json"
  cache: false
).done((resp) ->
  if (resp.error?)
    $.gritter.add(
      title: "error"
      text: resp.error
      time: 500
    )
  else if (resp.message and resp.message?)
    if (resp.image and resp.image?)
      $("#image").attr("src", resp.image)
    $("#message").get(0).innerHTML = resp.message
).fail(() ->
  $.gritter.add(
    title: "error"
    text: "something went wrong. could not load any of the entries."
    time: 500
  )
)

# show and hide the submit form
$("#submit-something").get(0).onclick = () ->
  $("#submit-dialog").show()

$("#chicken-out").get(0).onclick = () ->
  $("#submit-dialog").hide()

$("#submit-slander").get(0).onclick = () ->
  $.ajax(
    url: "/submit"
    dataType: "json"
    data: 
      message: $("#slander-message").val()
      image: $("#slander-image").val()
    type: "POST"
  ,).done((resp) ->
    if (resp.error?)
      $.gritter.add(
        title: "error"
        text: resp.error
        time: 500
      )
    else if (resp.success?)
      $.gritter.add(
        title: "success"
        text: resp.success
        time: 300
      )
  ).fail(() ->
    $.gritter.add(
      title: "error"
      text: "something went wrong. disliking simon more is not possible at this moment."
      time: 500
    )
  )

  $("#slander-message").val("")
  $("#slander-image").val("")
  $("#submit-dialog").hide()