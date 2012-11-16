class SiteClientMatcher
  
  def initialize(site)
    @site = site
    @removed_and_added_to_other_site = []
    @matched_but_unaffected = []
  end
  
  def self.site_matches_for_client_name(name)
    Site.select('id, name_filter, display_name').to_a.select{ |site| (name =~ Regexp.new("^#{site.name_filter}$", true) rescue false) }.sort_by{|site| -site.name_filter.length }
  end
  
  def effect_of_new_name_filter(filter)
    matches = get_matches(filter)
    if @site
      current = @site.clients.order(:name).to_a.collect{|c| {id: c.id, name: c.name, site: @site.display_name} }
      {
        to_be_added: matches - current,
        to_be_removed: (current - matches).delete_if{|r| r[:id].in? @removed_and_added_to_other_site.collect{|c| c[:id]}},
        to_be_removed_and_added_to_another_site: @removed_and_added_to_other_site,
        with_no_change: matches & current,
        matched_but_will_maintain_their_current_site: @matched_but_unaffected
      }
    else
      {
        'match'.pluralize(matches.length).to_sym => matches,
        :matched_but_will_maintain_their_current_site => @matched_but_unaffected
      }
    end
  end
  
  def get_matches(filter)
    Client.includes(:site)
            .order(:name)
            .to_a
            .select{|c| filter(c, filter) }
            .collect{|c| {id: c.id, name: c.name, site: c.try(:site).try(:display_name)} }
  end
  
  def filter(client, filter)
    if (client.name =~ Regexp.new("^#{filter}$", true) rescue false)
      return true if client.site_id.nil?
      if @site && @site.id == client.site_id
        if filter == client.site.name_filter
          return true
        else
          matches = SiteClientMatcher.site_matches_for_client_name(client.name)
          return true if matches.size == 1 || filter.length > matches[1].try(:name_filter).length
          @removed_and_added_to_other_site << {id: client.id, name: client.name, site: @site.display_name, new_site: matches[1].display_name}
        end
      else
        return true if filter.length > client.site.name_filter.length
        @matched_but_unaffected << {id: client.id, name: client.name, site: client.site.display_name}
      end
    else
      if @site && @site.id == client.site_id
        matches = SiteClientMatcher.site_matches_for_client_name(client.name)
        if matches.size > 1
          @removed_and_added_to_other_site << {id: client.id, name: client.name, site: @site.display_name, new_site: matches[1].display_name}
        end
      end
    end
    false
  end
  
end