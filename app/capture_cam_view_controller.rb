class CaptureCamViewController < UIViewController
  def viewDidAppear(animated)
    @cam_service = CameraService.new(view.layer)
    @cam_service.preview_layer.frame = view.frame

    @tap_gesture = UITapGestureRecognizer.alloc.initWithTarget(self, action: 'capture_image:')
    @tap_gesture.numberOfTapsRequired = 1
    view.addGestureRecognizer(@tap_gesture)
  end

  def viewDidDisappear(animated)
    view.removeGestureRecognizer(@tap_gesture)
  end

  def capture_image(gesture)
    @cam_service.capture_image
  end

  def viewDidLayoutSubviews
    if @cam_service
      @cam_service.preview_layer.frame = view.frame
    end
  end
end
