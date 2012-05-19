module KVO
  COLLECTION_OPERATIONS = [ NSKeyValueChangeInsertion, NSKeyValueChangeRemoval, NSKeyValueChangeReplacement ]
  DEFAULT_OPTIONS = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
  
  public
    def observe(target, key_path, &block)
      target.addObserver(self, forKeyPath:key_path, options:DEFAULT_OPTIONS, context:nil) unless registered?(target, key_path)
      add_observer_block(target, key_path, &block)
    end
      
    def unobserve(target, key_path)
      return unless registered?(target, key_path)
      
      target.removeObserver(self, forKeyPath:key_path)
      remove_observer_block(target, key_path)
    end
  
    def unobserve_all
      return if @targets.nil?
      
      @targets.each do |target, key_paths|
        key_paths.each_key do |key_path|
          target.removeObserver(self, forKeyPath:key_path)
        end  
      end
      remove_all_observer_blocks
    end
    
  private
    def registered?(target, key_path)
      !@targets.nil? && !@targets[target].nil? && @targets[target].has_key?(key_path)
    end
  
    def add_observer_block(target, key_path, &block)
      return if target.nil? || key_path.nil? || block.nil?
      
      @targets ||= {}
      @targets[target] ||= {}
      @targets[target][key_path] ||= []
      @targets[target][key_path] << block
    end
    
    def remove_observer_block(target, key_path)
      return if @targets.nil? || target.nil? || key_path.nil?
      
      key_paths = @targets[target]
      if !key_paths.nil? && key_paths.has_key?(key_path)
        key_paths.delete(key_path)
      end
    end
    
    def remove_all_observer_blocks
      @targets.clear unless @targets.nil?
    end
  
    # NSKeyValueObserving Protocol
    
  private
    def observeValueForKeyPath(key_path, ofObject:target, change:change, context:context)
      key_paths = @targets[target] || {}
      blocks = key_paths[key_path] || []
      blocks.each do |block|
        args = [ change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey] ]
        args << change[NSKeyValueChangeIndexesKey] if collection?(change)
        block.call(target, *args)
      end
    end
    
    def collection?(change)
      COLLECTION_OPERATIONS.include?(change[NSKeyValueChangeKindKey])
    end
    
end
