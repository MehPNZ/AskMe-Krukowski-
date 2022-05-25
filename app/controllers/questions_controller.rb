# frozen_string_literal: true

class QuestionsController < ApplicationController
  include ActionView::RecordIdentifier
  include QuestionsAnswers

  before_action :require_authentication, except: %i[show index]
  before_action :set_params, only: %i[edit update destroy show]
  before_action :authorize_question!
  after_action :verify_authorized

  def index
    @pagy, @questions = pagy Question.all_by_tags(params[:tag_ids]), 
      link_extra: 'data-turbo-frame="pagination_pagy"'
    @questions = @questions.decorate
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build question_params

    if @question.save
      respond_to do |format|
        format.html do
      redirect_to questions_path(@question), notice: t('flash.q_create')
        end 
        format.turbo_stream do
          @question = @question.decorate
          flash.now[:notice] = t('flash.q_create')
        end
      end
    else
      render :new
    end
  end

  def update
    if @question.update question_params
      respond_to do |format|
        format.html do
          redirect_to questions_path(anchor: dom_id(@question)), notice: t('flash.q_update')
        end
        format.turbo_stream do
          @question = @question.decorate
          flash.now[:notice] = t('flash.q_update')
       end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit; end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html do
    redirect_to questions_path, status: 303, notice: t('flash.q_delete')
      end

      format.turbo_stream { flash.now[:notice] = t('flash.q_delete')}
    end
  end

  def show
    load_question_answer
  end

  private

  def question_params
    params.require(:question).permit(:title, :body, tag_ids: [])
  end

  def set_params
    @question = Question.find(params[:id])
  end

  # def fetch_tags
  #   @tags = Tag.all
  # end

  def authorize_question!
    authorize(@question || Question)
  end
end
