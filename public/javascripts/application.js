// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

$(document).ready(function() {
  $("#game_filter").change(function() {$.ajax({url: this.action + ".js", data: $(this).serialize(), dataType: "script"});});
  $("#bbcode_link").click(function() {$(this).attr("href", this.href+"?"+$("#game_filter").serialize());});
})