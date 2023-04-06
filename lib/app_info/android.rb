# frozen_string_literal: true

require 'app_info/android/signature'
require 'image_size'
require 'forwardable'

module AppInfo
  # Android base parser for apk and aab file
  class Android < File
    extend Forwardable
    include Helper::HumanFileSize

    # return file size
    # @example Read file size in integer
    #   aab.size                    # => 3618865
    #
    # @example Read file size in human readabale
    #   aab.size(human_size: true)  # => '3.45 MB'
    #
    # @param [Boolean] human_size Convert integer value to human readable.
    # @return [Integer, String]
    def size(human_size: false)
      file_to_human_size(@file, human_size: human_size)
    end

    # @return [Symbol] {Platform}
    def platform
      Platform::GOOGLE
    end

    # @return [Symbol] {OperaSystem}
    def opera_system
      OperaSystem::ANDROID
    end

    # @return [Symbol] {Device}
    def device
      if watch?
        Device::WATCH
      elsif television?
        Device::TELEVISION
      elsif automotive?
        Device::AUTOMOTIVE
      elsif tablet?
        Device::TABLET
      else
        Device::PHONE
      end
    end

    # @abstract Subclass and override {#name} to implement.
    def name
      not_implemented_error!(__method__)
    end

    # @todo find a way to detect, no way!
    # @see https://stackoverflow.com/questions/9279111/determine-if-the-device-is-a-smartphone-or-tablet
    # @return [Boolean] false always false
    def tablet?
      # Not works!
      # resource.first_package
      #         .entries('bool')
      #         .select{|e| e.name == 'isTablet' }
      #         .size >= 1
      false
    end

    # @return [Boolean]
    def watch?
      !!use_features&.include?('android.hardware.type.watch')
    end

    # @return [Boolean]
    def television?
      !!use_features&.include?('android.software.leanback')
    end

    # @return [Boolean]
    def automotive?
      !!use_features&.include?('android.hardware.type.automotive')
    end

    # @abstract Subclass and override {#use_features} to implement.
    def use_features
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#use_permissions} to implement.
    def use_permissions
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#use_permissions} to implement.
    def activities
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#use_permissions} to implement.
    def services
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#use_permissions} to implement.
    def components
      not_implemented_error!(__method__)
    end

    # Return multi version certifiates of signatures
    # @return [Array<Hash>] signatures
    # @see AppInfo::Android::Signature.verify
    def signatures
      @signatures ||= Android::Signature.verify(self)
    end

    # Legacy v1 scheme signatures, it will remove soon.
    # @deprecated Use {#signatures}
    # @return [Array<OpenSSL::PKCS7, nil>] signatures
    def signs
      @signs ||= v1sign&.signatures || []
    end

    # Legacy v1 scheme certificates, it will remove soon.
    # @deprecated Use {#signatures}
    # @return [Array<OpenSSL::PKCS7, nil>] certificates
    def certificates
      @certificates ||= v1sign&.certificates || []
    end

    # @abstract Subclass and override {#manifest} to implement.
    def manifest
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#resource} to implement.
    def resource
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#zip} to implement.
    def zip
      not_implemented_error!(__method__)
    end

    # @abstract Subclass and override {#clear!} to implement.
    def clear!
      not_implemented_error!(__method__)
    end

    # @return [String] contents path of contents
    def contents
      @contents ||= ::File.join(Dir.mktmpdir, "AppInfo-android-#{SecureRandom.hex}")
    end

    protected

    def v1sign
      @v1sign ||= Android::Signature::V1.verify(self)
    rescue Android::Signature::NotFoundError
      nil
    end
  end
end
