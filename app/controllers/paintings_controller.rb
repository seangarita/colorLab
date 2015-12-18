class PaintingsController < ApplicationController
  before_action :set_painting, :only => :destroy

  # GET /paintings
  # GET /paintings.json
  def index
    @paintings = Painting.all
  end


  # GET /paintings/new
  def new
    @painting = Painting.new
  end

  # POST /paintings
  # POST /paintings.json
  def create
    @painting = Painting.new(painting_params)

    respond_to do |format|
      if @painting.save
        format.html { redirect_to paintings_url, notice: 'Painting was successfully created.' }
        format.json { render :show, status: :created, location: @painting }
      else
        format.html { redirect_to paintings_url, notice: 'Painting was not created.' }
        format.json { render json: @painting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paintings/1
  # DELETE /paintings/1.json
  def destroy
    @painting.destroy
    respond_to do |format|
      format.html { redirect_to paintings_url, notice: 'Painting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_painting
      @painting = Painting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def painting_params
      params.require(:painting).permit(:binary)
    end
end
