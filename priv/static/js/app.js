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
      }
    }

    $("#sync").on('click', Credo.sync);
});
