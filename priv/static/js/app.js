$(document).ready(() => {
    Credo = {
      refresh : function() {
        window.location.href = window.location.href;
      },
      sync : function(e) {
        var btn = $(e.target)
          .attr("disabled", "disabled")
          .addClass("loading");
        $.get('/repos/sync')
          .done(Credo.refresh)
          .fail(function() {
            btn.removeAttr("disabled").removeClass("loading");
        });
      },
      toggleWebhook : function(e) {
        e.preventDefault();
        var btn = $(e.target);
        var form = $(this.form);
        var url = form.attr('action');
        var type = btn.is('.on')? "DELETE" : "POST"

        //Toggle status to have inmediate feedback
        Credo.toggleStatus(btn);

        $.ajax({
          type: type,
          url: url,
          data: form.serialize(), // serializes the form's elements.
          error: function(data){
            alert('There was an error, please try again')
            //Restore to prevous status if something goes wrong
            Credo.toggleStatus(btn);
          }
        });
      },
      toggleStatus : function(button) {
        if(button.is('.on')){
          button.removeClass('on').addClass('off');
        }else{
          button.removeClass('off').addClass('on');
        }
      },
    }

    $("#sync").on('click', Credo.sync);
    $(".add-remove-hook-form .repo-btn").on('click', Credo.toggleWebhook);
});
