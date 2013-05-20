do_action = (elm) ->
  action = ""
  if ($(elm).attr("accept")?)
    action = "accept"
  else if ($(elm).attr("delete")?)
    action = "delete"

  $.ajax(
    url: "/back/admin"
    type: "POST"
    dataType: "json"
    cache: false
    data:
      password: $("#password").val()
      id: $(elm).attr(action)
      action: action
  ).done((resp) ->
    if (resp.error?)
      $.gritter(
        title: "error"
        text: resp.error
        time: 3000
      )
    else
      $(elm).parent().addClass("hide")
  ).fail(() ->
    $.gritter(
      title: "error"
      text: "unknown error has occured. message could not be accepted."
      time: 3000
    )
  )

load_messages = () ->
  $.ajax(
    url: "/back/admin"
    type: "GET"
    dataType: "json"
    cache: false
    data:
      password: $("#password").val()
  ).done((resp) ->
    if (resp.error?)
      $.gritter.add(
        title: "error"
        text: resp.error
        time: 3000
      )
    else if (resp.messages and resp.messages?)
      for message in resp.messages
        clone = $("#item-template").get(0).cloneNode(true)
        $(clone).children("h4").each(() ->
          $(this).get(0).innerHTML = message.message
        )
        if (message.image and message.image?)
          $(clone).children("a").each(() ->
            $(this).get(0).href = message.image
            $(this).removeClass("hide")
          )
        
        $(clone).children("button.action").each(() ->
          if ($(this).attr("accept")?)
            $(this).attr("accept", message.id)
            $(this).get(0).onclick = () ->
              do_action(this)
          else if ($(this).attr("delete")?)
            $(this).attr("delete", message.id)
            $(this).get(0).onclick = () ->
              do_action(this)
        )

        $(clone).removeAttr("id")
        $(clone).removeClass("hide")
        $("#slanderous-messages").get(0).appendChild(clone)
  ).fail(() ->
    $.gritter.add(
      title: "error"
      text: "something went wrong. could not load any of the entries."
      time: 3000
    )
  )

# load the entries
$("#load-messages").on("click", () ->
  if ($("#slanderous-messages").children("div").length is 1)
    load_messages()
)