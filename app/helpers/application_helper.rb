module ApplicationHelper
  def sortable_link(column, label)
    current_sort = params[:sort]
    current_dir  = params[:dir]
    is_active    = current_sort == column
    new_dir      = is_active && current_dir == "asc" ? "desc" : "asc"
    indicator    = is_active ? (current_dir == "asc" ? " ▲" : " ▼") : ""

    link_to(
      safe_join([ label, content_tag(:span, indicator, class: "text-indigo-500") ]),
      url_for(request.query_parameters.merge(sort: column, dir: new_dir)),
      class: "font-semibold text-gray-700 dark:text-gray-300 hover:text-indigo-600 dark:hover:text-indigo-400"
    )
  end

  def player_avatar(player, size: :sm)
    px = size == :sm ? 32 : 64

    img = if player.profile_picture.attached?
      thumb = player.profile_picture.variant(resize_to_fill: [ px, px ])
      image_tag(thumb,
        width: px, height: px,
        class: "inline-block rounded-full object-cover",
        alt: player.name)
    else
      content_tag(:span,
        player.name.first.upcase,
        class: "inline-flex items-center justify-center rounded-full bg-indigo-100 dark:bg-indigo-900 text-indigo-700 dark:text-indigo-300 font-semibold text-xs select-none",
        style: "width:#{px}px;height:#{px}px;flex-shrink:0;")
    end

    link_to img, player_path(player)
  end

  def game_link(game)
    link_to game.name, game_path(game),
      class: "text-indigo-600 dark:text-indigo-400 hover:underline font-medium"
  end

  def safe_external_url(url)
    uri = URI.parse(url.to_s)
    %w[http https].include?(uri.scheme) ? uri.to_s : nil
  rescue URI::InvalidURIError
    nil
  end

  def breadcrumbs(*items)
    content_for :breadcrumbs do
      safe_join(
        items.map.with_index do |(label, path), i|
          last = i == items.length - 1
          if last || path.nil?
            content_tag(:span, label, class: "text-gray-500 dark:text-gray-400")
          else
            link_to(label, path, class: "hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors")
          end
        end,
        content_tag(:span, " / ", class: "mx-1 text-gray-400 dark:text-gray-600 select-none")
      )
    end
  end
end
