navigation_enabled = true

go_backwards = () ->
  if (navigation_enabled)
    console.log("go backwards")

go_forwards = () ->
  if (navigation_enabled)
    console.log("go forwards")

# Show and hide the submit form
$("#submit-something").get(0).onclick = () ->
  $("#submit-dialog").show()
  navigation_enabled = false

$("#chicken-out").get(0).onclick = () ->
  $("#submit-dialog").hide()
  navigation_enabled = true

$("#submit-slander").get(0).onclick = () ->
  $.ajax(
    url: "/submit",
    dataType: "json",
    data: 
      message: $("#slander-message").val()
      image: $("#slander-image").val()
    type: "POST"
  ,).done((resp) ->
    console.dir(resp)
  ).fail((jqXHR, e_status, e_thrown) ->
    alert("something went wrong. anarchy not possible at this moment.")
    console.log(e_status)
    console.log(e_thrown)
  )

  console.log("submitted message: " + $("#slander-message").val())
  console.log("submitted image: " + $("#slander-image").val())

  $("#slander-message").val("")
  $("#slander-image").val("")
  $("#submit-dialog").hide()
  navigation_enabled = true

# Bind our keys
$(document).on("keyup", null, "left", () ->
  go_backwards()
)

$(document).on("keyup", null, "a", () ->
  go_backwards()
)

$(document).on("keyup", null, "right", () ->
  go_forwards()
)

$(document).on("keyup", null, "d", () ->
  go_forwards()
)