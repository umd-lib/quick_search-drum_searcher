Rails.application.routes.draw do
  mount QuickSearchDRUMSearcher::Engine => "/quick_search-drum_searcher"
end
