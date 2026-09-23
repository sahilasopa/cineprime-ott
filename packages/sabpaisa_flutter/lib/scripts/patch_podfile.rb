module SabPaisaPatch
  def self.run(installer)
    schemes = %w[
      phonepe bhim tez paytm gpay credpay icici myairtel payzapp axismobile
      freecharge slice-upi olamoney sbiyono paytmmp mobikwik kmb
    ]

    installer.aggregate_targets.each do |aggregate_target|
      aggregate_target.user_project.native_targets.each do |target|
        next unless target.respond_to?(:product_type) && target.product_type == "com.apple.product-type.application"

        target.build_configurations.each do |config|
          plist_path = config.build_settings["INFOPLIST_FILE"]
          next unless plist_path

          plist_file = File.expand_path(File.join(File.dirname(aggregate_target.user_project.path), plist_path))
          next unless File.exist?(plist_file)

          puts "⚡️ [sabpaisa-react-lib-lite] Patching #{plist_file}"

          # Always reset LSApplicationQueriesSchemes
          system("/usr/libexec/PlistBuddy", "-c", "Delete :LSApplicationQueriesSchemes", plist_file) rescue nil
          system("/usr/libexec/PlistBuddy", "-c", "Add :LSApplicationQueriesSchemes array", plist_file)

          # Add each scheme in order
          schemes.each_with_index do |scheme, idx|
            system("/usr/libexec/PlistBuddy", "-c", "Add :LSApplicationQueriesSchemes:#{idx} string #{scheme}", plist_file)
          end
        end
      end
    end
  end
end
