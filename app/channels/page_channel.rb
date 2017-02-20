class PageChannel < ApplicationCable::Channel
  def subscribed
    stream_from "page_channel_#{params[:url]}"
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def pet
    params[:url].downcase!
    @page = Page.find_by! url: params[:url]
    petting_params = {
      petted_id: @page.pet_id,
      petted_at: DateTime.now.utc
    }
    if current_pet
      petting_params[:petter_id] = current_pet.id
    end
    @petting = Petting.new(petting_params)
    if @petting.save
      ActionCable.server.broadcast "page_channel_#{@page.url}",
        petter: @petting.petter ? { name: @petting.petter.name, url: @petting.petter.page.url } : false,
        petted_at: @petting.petted_at,
        pet_count: @page.pet.received_pettings.count
      ActionCable.server.broadcast "stats_channel",
        total_pets: Pet.all.count,
        total_pettings: Petting.all.count
    end
  end
end
