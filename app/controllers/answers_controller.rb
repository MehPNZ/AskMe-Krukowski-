# frozen_string_literal: true

class AnswersController < ApplicationController
  include ActionView::RecordIdentifier
  include QuestionsAnswers

  before_action :set_question!
  before_action :set_answer!, except: %i[create]
  before_action :authorize_answer!
  after_action :verify_authorized

  def create
    @answer = @question.answers.build(params_answer_create)

    if @answer.save
      respond_to do |format|
        format.html do
      redirect_to question_path(@question), notice: t('flash.answer_create')
        end
        format.turbo_stream do
          @answer = @answer.decorate
          flash.now[:notice] = t('flash.answer_create')
      end
    end
    else
      load_question_answer(do_render: true)
    end
  end

  def update
    if @answer.update(params_answer_update)
      respond_to do |format|
        format.html do
      redirect_to question_path(@question, anchor: dom_id(@answer)), notice: t('flash.answer_update')
        end
        format.turbo_stream do
          @answer = @answer.decorate
          flash.now[:notice] = t('flash.answer_update')
        end
      end
    else
      render :edit
    end
  end

  def new
    @answer = Answer.new
  end

  def destroy
    @answer.destroy
    respond_to do |format|
      format.html do
    redirect_to question_path(@question), status: 303, notice: t('flash.answer_delete')
      end

      format.turbo_stream {flash.now[:notice] = t('flash.answer_delete')}
    end
  end

  def edit; end

  private

  def params_answer_create
    params.require(:answer).permit(:body).merge(user_id: current_user.id)
  end

  def params_answer_update
    params.require(:answer).permit(:body)
  end

  def set_question!
    @question = Question.find(params[:question_id])
  end

  def set_answer!
    @answer = @question.answers.find(params[:id])
  end

  def authorize_answer!
    authorize(@answer || Answer)
  end
end
