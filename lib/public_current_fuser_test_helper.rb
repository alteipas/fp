module PublicCurrentFuserTestHelper
  module RedefinedMethods
    def current_fuser
      super
    end
    def current_fuser=(new)
      super(new)
    end
  end
  ApplicationController.send(:include,RedefinedMethods)

end

