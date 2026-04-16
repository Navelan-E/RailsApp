// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

function showToast() {
  const flash = document.getElementById("flash");
  if (!flash) return;

  const notice = flash.dataset.notice;
  const alert = flash.dataset.alert;

  if (notice && notice !== "undefined") {
    toastr.success(notice);
    flash.removeAttribute("data-notice"); // Clear the attribute entirely
  }
  
  if (alert && alert !== "undefined") {
    toastr.error(alert);
    flash.removeAttribute("data-alert"); // Clear the attribute entirely
  }
}

// Keep your listeners as they are
document.addEventListener("turbo:load", showToast);
document.addEventListener("turbo:render", showToast);