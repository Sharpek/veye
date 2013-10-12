
class BaseCSV
  def initialize(headers)
    @columns = headers
  end

  def before
    puts @columns
  end
  def after(paging, allow_pagination = false)
    if allow_pagination && !paging.nil?
      printf("# ------------------------------------------\n")
      printf("current_page,per_page,total_pages,total_entries\n")
      printf("%s,%s,%s,%s\n",
            paging['current_page'],
            paging['per_page'],
            paging['total_pages'],
            paging['total_entries'])
    end
  end

  def format(results)
    raise NotImplementedError
  end
end

