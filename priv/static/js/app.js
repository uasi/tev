'use strict'

// Register scroll event handler that enables intinite scroll.
$(function () {
  // Context is defined only in the index page.
  var ctx = window.infiniteScrollContext
  if (ctx == null || ctx.nextPage == null) { return }

  var $boxContainer = $('#box-container')
  var $spinner = $('#spinner')
  var throttleInterval = 200
  var scrollOffsetLeeway = 200
  var last = 0

  $(document).scroll(ctx.handler = function () {
    if (ctx.isLoading) { return }

    if (ctx.nextPage == null) {
      $(document).off('scroll', ctx.handler)
      return
    }

    var now = +new Date()
    if (last > now - throttleInterval) { return }
    last = now

    var scrollOffset = $(document).scrollTop() + window.innerHeight
    var boxContainerBottomOffset = $boxContainer.offset().top + $boxContainer.height()
    if (!ctx.isLoading && scrollOffset + scrollOffsetLeeway > boxContainerBottomOffset) {
      loadMore(ctx, $boxContainer, $spinner)
    }
  })
})

function loadMore (ctx, $boxContainer, $spinner) {
  ctx.isLoading = true
  $spinner.removeClass('hidden')

  $.getJSON('/api/rendered_tweets?page=' + ctx.nextPage, function (data) {
    ctx.isLoading = false
    ctx.nextPage = data.next_page
    $boxContainer.append(data.html)
    $spinner.addClass('hidden')
  })
}
