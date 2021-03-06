module TPerformanceHelper
  #
  # Get HTML for 'settings' menu for sorting
  #
  def get_settings
    path = request.env['PATH_INFO'] # Get current request path

    if path.include?('performances') || path.include?('posters')
      a = get_setting_vals(path) # Get settings values from path

      # Recreate path, for links
      /(\/\w+).*/ =~ path
      cl = "<a href='#{$1}' class='btn btn-primary'>" + t(:g_clear) + '</a>'
      nm = $1 + get_new_path(a)
      r = ''

      # Create different menus for different paths
      if path == '/posters'

        # Add 'Type' and 'Month' menus
        r += get_menus(nm, a, %w(type month))

        # Add 'More' and 'Clear' buttons
        r += '<button class="btn btn-primary" data-toggle="collapse" '
        r += '   data-target="#perf-types" style="margin-right:10px">' + t(:m_more) + '</button>'
        r += cl + '</div>'


        # Start 'More' menu
        b = %w(theatre name day time)
        open = has_one_par?(b)
        r += '<div class="perf-types"><div class="collapse' + (open ? ' open in' : '') + '" id="perf-types">'

        # Add 'Theatre' menu
        r += get_menus(nm, a, b)

        # Close 'More' menu
        r += '</div>'
      elsif path == '/performances'
        r += get_menus(nm, a, %w(type theatre))

        # Add 'Clear' button
        r += cl

      else
        r += get_menus(nm, a, %w(type theatre))

        if user_signed_in?
          /\/\w+\/(\d+)/ =~ path
          r += '<div class="pull-right"><a href="/favorites/add/' + $1 + '" class="btn btn-primary">Добавить в закладки</a></div>'
        end
      end

      r
    else
      'Not in performances or posters'
    end
  end


  # Recreate path for sorting links
  #  sett::settings array
  def get_new_path (sett)
    nm = '?'

    sett.each {|k, v| # Append params
      nm += v > 0 ? "by_#{k}=#{v}&" : ''
    }

    del_tail(nm)
  end


  # Delete trailing ? and & symbols
  #  url:: string
  def del_tail(url)
    /(.*\w+)(\?|&)*/ =~ url
    if $1
      $1
    else
      ''
    end
  end


  # Get HTML for each menu in arr
  #  url:: link prefix
  #  sett:: settings array
  #  arr:: sett keys array
  def get_menus (url, sett, arr)
    r = ''
    arr.each {|v|
      r += get_menu(url, sett, v)
    }

    r
  end


  # Get HTML for menu
  #  url:: link prefix
  #  sett:: settings array
  #  type:: sett key
  def get_menu (url, sett, type)
    t_name = get_def_name(sett, type)
    collection = get_collection(type)

    # Delete old id from str
    url = del_tail(url.gsub(/by_#{type}=\d+&*/, ''))

    # Create url for link without current menu setting
    /(\/\w+)(\?|&)*/ =~ url
    b_url = "#{$1}?by_#{type}=#{sett[type]}" if sett[type] != 0

    # Menu 'Header'
    r = '<div class="btn-group dropdown" style="margin-right:10px;">'
    r += "<a href=\"#{b_url}\" class=\"btn btn-primary\"  data-hover=\"dropdown\" >" + t_name + '</a>'
    r += '<button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">'
    r += '<span class="caret"></span></button>'
    r += '<ul class="dropdown-menu" role="menu">'

    # First link for 'clear current' action
    r += '<li><a href="' + del_tail(url) + '" >' + t(:m_none) + '</a>'

    # Append ? or & symbols to url
    url += '?' if url == '/performances' || url == '/posters'
    url += '&' unless url.end_with?('?', '&')

    # Append all items from list
    collection.each {|k, v|
      r += "<li><a href='#{url}by_#{type}=#{k.to_s}'>#{v}</a></li>"
    }

    # Close menu
    r + '</ul></div>'
  end


  # Get name for setting button
  #  if id == 0, then default
  #  if id != 0, then find in list
  #
  #  sett:: settings array
  #  type:: sett key
  def get_def_name(sett, type)
    i = sett[type]
    if i > 0
      get_collection(type)[i]
    else
      t("m_#{type}_default")
    end
  end


  # Get collection
  #  type:: sett key
  def get_collection(type)
    UtilsHelper.get_hash(get_list_name(type))
  end


  # Get name for UtilsHelper .get_hash and .find_in_list
  #  type:: sett key
  def get_list_name(type)
    case (type)
      when 'name'
        type = 'performances'
      when 'theatre'
        type = 'theatres'
      when 'type'
        type = 'p_types'
      else
        ;
    end

    type
  end


  # Get values for current page
  #  path:: request path
  def get_setting_vals(path)
    a = get_def_sett_vals

    if /\/\w+\/(\d+)/ =~ path # If it's performance page [/performances/14]
      perf = TPerformance.get_setting_vals($1)
      perf.each {|k, v|
        a[k] = v
      }

    else # If has parameters [/performances?by_type=1&...]
      a.each_key {|k|
        if params.include?('by_' + k)
          a[k] = params['by_' + k].to_i
        end
      }
    end

    a
  end


  # Костыль
  # Because of Ruby >1.9, when creating hash with quick syntax
  #  a = {k: v}, Ruby converting k to symbol.
  #  But string needed as key for lists and etc.
  #
  def get_def_sett_vals
    a = {}

    a['month'] = 0
    a['day'] = 0
    a['time'] = 0
    a['type'] = 0
    a['name'] = 0
    a['theatre'] = 0

    a
  end


  # Has params specified parameters ?
  #  a:: parameters
  def has_one_par? (a)
    r = false

    a.each {|k|
      r ||= params.include?('by_' + k)
    }

    r
  end
end
