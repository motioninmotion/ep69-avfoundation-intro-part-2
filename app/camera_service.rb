class CameraService
  attr_reader :preview_layer, :parent_layer

  def initialize(parent_layer)
    @parent_layer = parent_layer
    configure
    start
  end

  def session
    @session ||= AVCaptureSession.new
  end

  def capture_image
    @image_output.captureStillImageAsynchronouslyFromConnection(
      @image_output.connectionWithMediaType(AVMediaTypeVideo),
      completionHandler: -> (image_buffer, _) {
        if image_buffer
          data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(image_buffer)
          image = UIImage.alloc.initWithData(data)
          PHPhotoLibrary.sharedPhotoLibrary.performChanges(-> {
            PHAssetChangeRequest.creationRequestForAssetFromImage(image)
          }, completionHandler: nil)
        end
      })
  end

  private

  def start
    session.startRunning
  end

  def configure
    session.beginConfiguration

    if session.canSetSessionPreset(AVCaptureSessionPresetHigh)
      session.sessionPreset = AVCaptureSessionPresetHigh
    end

    acceptableVideoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).select do |device|
      device.position == AVCaptureDevicePositionBack
    end

    if acceptableVideoDevices.count > 0
      input = AVCaptureDeviceInput.deviceInputWithDevice(acceptableVideoDevices.first, error: nil)

      session.addInput(input) if session.canAddInput(input)
    end

    @preview_layer = AVCaptureVideoPreviewLayer.alloc.initWithSession(session)
    @parent_layer.addSublayer(@preview_layer)

    @image_output = AVCaptureStillImageOutput.new
    @image_output.highResolutionStillImageOutputEnabled = true
    @image_output.outputSettings = { AVVideoCodecKey => AVVideoCodecJPEG }

    session.addOutput(@image_output) if session.canAddOutput(@image_output)

    session.commitConfiguration
  end
end
