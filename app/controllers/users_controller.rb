class UsersController < ApplicationController
  before_filter :require_user, :only => [:new_user, :add_new_user, :manage_users]
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
#  def show
#    @user = User.find(params[:id])

#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @user }
#    end
#  end

  def new_user
    @user = User.new
    @user.account_id = current_user.account_id
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def add_new_user
    @user = User.new(params[:user])
    password = random_password(10)
    @user.password = password
    @user.password_confirmation = password

      @user.save!
      @user.deliver_confirmation_email!
      flash[:notice] = "An email notification has been sent to the new user"
    redirect_to manage_users_path
  end

  def manage_users
    @users = User.find_all_by_account_id(current_user.account_id)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    account = Account.new
    respond_to do |format|
      if account.save
        @user.account_id = account.id
        if @user.save
          flash[:notice] = 'Registration successful'
          format.html { redirect_to root_url }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      else
        flash[:warning] = 'Registration failed'
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to root_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private
  def random_password(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    return Array.new(10){||chars[rand(chars.size)]}.join
  end
end
