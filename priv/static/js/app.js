'use strict'

// Register scroll event handler that enables intinite scroll.
$(function () {
  // Context is defined only in the index page.
  var ctx = window.infiniteScrollContext
  if (ctx == null) { return }

  var $boxContainer = $('#box-container')
  var $spinner = $('#spinner')
  var throttleInterval = 200
  var scrollOffsetLeeway = 200
  var last = 0

  $(document).scroll(ctx.handler = function () {
    if (ctx.isLoading) { return }

    if (ctx.nextPage == null) {
      loadNoMore(ctx)
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

  var params = { timeline_type: ctx.timelineType, page: ctx.nextPage }
  $.getJSON('/api/rendered_tweets', params, function (data) {
    ctx.isLoading = false
    ctx.nextPage = data.next_page
    $boxContainer.append(data.html)
    $spinner.addClass('hidden')
  })
}

function loadNoMore (ctx) {
  $(document).off('scroll', ctx.handler)

  var $sentinel = $('#sentinel')
  if ($sentinel.length) {
    $sentinel.removeClass('hidden')
  }
}
